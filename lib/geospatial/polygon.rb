# Copyright, 2016, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'box'

module Geospatial
	class Polygon
		def self.[] *points
			self.new(points)
		end
		
		def self.load(data)
			if data
				self.new(JSON.parse(data).map{|point| Vector.elements(point)})
			end
		end
		
		def self.dump(polygon)
			if polygon
				JSON.dump(polygon.points.map(&:to_a))
			end
		end
		
		def initialize(points, bounding_box = nil)
			@points = points
			@bounding_box = bounding_box
		end
		
		attr :points
		
		def [] index
			a = @points[index.floor]
			b = @points[index.ceil % @points.size]
			
			return a + (b - a) * (index % 1.0)
		end
		
		def to_s
			"#{self.class}#{@points.inspect}"
		end
		
		def bounding_box
			@bounding_box ||= Box.enclosing_points(@points).freeze
		end
		
		def freeze
			@points.freeze
			bounding_box.freeze
			
			super
		end
		
		def edges
			return to_enum(:edges) unless block_given?
			
			size = @points.size
			
			@points.each_with_index do |point, index|
				yield point, @points[(index+1)%size]
			end
		end
		
		# @param [Float] radius The radius of the sphere on which to compute the area.
		def area(radius = 1.0)
			if @points.size > 2
				area = 0.0
				
				self.edges.each do |p1, p2|
					r1 = (p2[0] - p1[0]) * D2R
					r2 = 2 + Math::sin(p1[1] * D2R) + Math::sin(p2[1] * D2R)
					
					area += r1 * r2
				end
				
				return (area * radius * radius / 2.0).abs
			else
				return 0.0
			end
		end
		
		def simplify
			simplified_points = @points.first(1)
			
			@points.each_with_index do |point, index|
				next_point = @points[(index+1) % @points.size]
				
				if yield(simplified_points.last, point, next_point)
					simplified_points << point
				end
			end
			
			self.class.new(simplified_points, bounding_box)
		end
		
		# @example
		# polygon.subdivide do |a, b|
		# 	if a.distance_from(b) > maximum_distance
		# 		a.midpoints(b, 2)
		# 	end
		# end
		def subdivide
			simplified_points = @points.first(1)
			
			@points.each_with_index do |point, index|
				next_point = @points[(index+1) % @points.size]
				
				if points = yield(simplified_points.last, point, next_point)
					simplified_points.concat(points)
				else
					simplified_points << point
				end
			end
			
			self.class.new(simplified_points, bounding_box)
		end
		
		def self.is_left(p0, p1, p2)
			a = p1 - p0
			b = p2 - p0
			
			return (a[0] * b[1]) - (b[0] * a[1])
		end
		
		# Test a 2D point for inclusion in the polygon.
		# @param [Vector] p The point to test.
		# @return [Number] The number of times the polygon winds around the point (0 if outside).
		def winding_number(p)
			count = 0
			
			edges.each do |pa, pb|
				if pa[1] <= p[1]
					if pb[1] >= p[1] and Polygon.is_left(pa, pb, p) > 0
						count += 1
					end
				else
					if pb[1] <= p[1] and Polygon.is_left(pa, pb, p) < 0
						count -= 1
					end
				end
				
			end
			
			return count
		end
		
		def include_point?(point)
			return false unless bounding_box.include_point?(point)
			
			self.winding_number(point).odd?
		end
		
		def intersect_with_box?(other)
			return true if @points.any?{|point| other.include_point?(point)}
			
			return true if other.corners.any?{|corner| self.include_point?(corner)}
			
			return false
		end
		
		def edge_intersection(a, b)
			line = Line.new(a, b)
			
			edges.each_with_index do |(pa, pb), i|
				edge = Line.new(pa, pb)
				
				if line.intersect?(edge)
					return i
				end
			end
			
			return nil
		end
		
		def intersect?(other)
			case other
			when Box
				intersect_with_box?(other)
			when Circle
				intersect_with_circle?(other)
			end
		end
		
		def include?(other)
			other.corners.all?{|corner| self.include_point?(corner)}
		end
	end
end
