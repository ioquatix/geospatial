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
		
		def initialize(points, bounding_box = nil)
			@points = points
			@bounding_box = bounding_box
		end
		
		attr :points
		
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
			
			previous = @points.last
			@points.each do |point|
				yield previous, point
				previous = point
			end
		end
		
		def simplify(minimum_distance = 1)
			simplified_points = @points.first(1)
			
			@points.each do |point|
				distance = (point - simplified_points.last).magnitude
				
				if distance > minimum_distance
					simplified_points << point
				end
			end
			
			self.new(simplified_points, bounding_box)
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
			
			self.winding_number(point) == 1
		end
		
		def intersect_with_box?(other)
			return true if @points.any?{|point| other.include_point?(point)}
			
			return true if other.corners.any?{|corner| self.include_point?(corner)}
			
			return false
		end
		
		def edge_intersection(a, b)
			line = Line.new(a, b)
			
			edges.each_with_index do |pa, pb, i|
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
