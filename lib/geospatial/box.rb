# Copyright, 2015, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'matrix'

module Geospatial
	class Box
		class << self
			def from_bounds(min, max)
				self.new(min, max-min, max)
			end
			
			alias [] from_bounds
			
			def enclosing_points(points)
				return nil unless points.any?
				
				min = points.first.to_a
				max = points.first.to_a
				
				points.each do |point|
					point.each_with_index do |value, index|
						if value < min[index]
							min[index] = value
						elsif value > max[index]
							max[index] = value
						end
					end
				end
				
				return self.from_bounds(Vector.elements(min), Vector.elements(max))
			end
		end
		
		def initialize(origin, size, max = nil)
			@origin = origin
			@size = size
			@max = max
		end
		
		def freeze
			self.max
			
			super
		end
		
		attr :origin
		attr :size
		
		def to_s
			"#{self.class}[#{min.inspect}, #{max.inspect}]"
		end
		
		def min
			@origin
		end
		
		def max
			@max ||= @origin + @size
		end
		
		# This yields the four corners of the box.
		def corners
			return to_enum(:corners) unless block_given?
			
			yield(@origin)
			
			max = self.max
			yield(Vector[max[0], @origin[1]])
			yield(max)
			yield(Vector[@origin[0], max[1]])
		end
		
		def center
			@origin + (@size/2)
		end
		
		# This yields the midpoints of the four sides of the box.
		def midpoints
			return to_enum(:midpoints) unless block_given?
			
			size = self.size
			
			yield(Vector[@origin[0] + size[0] / 2, @origin[1]])
			yield(Vector[@origin[0] + size[0], @origin[1] + size[1] / 2])
			yield(Vector[@origin[0] + size[0] / 2, @origin[1] + size[1]])
			yield(Vector[@origin[0], @origin[1] + size[1] / 2])
		end
		
		def include_point?(point)
			2.times do |i|
				return false if point[i] < min[i] or point[i] >= max[i]
			end
			
			return true
		end
		
		def include?(other)
			include_point?(other.min) && include_point?(other.max)
		end
		
		def intersect?(other)
			2.times do |i|
				# Separating axis theorm, if the minimum of the other is past the maximum of self, or the maximum of other is less than the minimum of self, an intersection cannot occur.
				if other.min[i] > self.max[i] or other.max[i] < self.min[i]
					return false
				end
			end
			
			return true
		end
	end
end
