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
	class Circle
		# Center must be a vector, radius must be a numeric value.
		def initialize(center, radius)
			@center = center
			@radius = radius
		end
		
		attr :center
		attr :radius
		
		def inspect
			"#{self.class}(#{@center} -> #{@radius})"
		end
		
		def contains_point?(point)
			
			
			dimensions.times do |i|
				return false if point[i] < min[i] or point[i] >= max[i]
			end
			
			return true
		end
		
		def contains?(other)
			contains_point?(other.min) && contains_point?(other.max)
		end
		
		def intersects?(other)
			dimensions.times do |i|
				# Separating axis theorm, if the minimum of the other is past the maximum of self, or the maximum of other is less than the minimum of self, an intersection cannot occur.
				if other.min[i] > self.max[i] or other.max[i] < self.min[i]
					return false
				end
			end
			
			return true
		end
		
		def integral_offset(coordinate, scale)
			dimensions.times.collect do |i|
				Integer((coordinate[i] - @origin[i]).to_f / @size[i] * scale)
			end
		end
		
		def intersects(other)
			case other
			when Sphere
				intersects_with_sphere(other)
			else
				raise UnimplementedError.new("Can't compute intersection of #{self.class} and #{other.class}")
			end
		end
		
		# This function needs to handle distances in space which wraps. It currently doesn't do that.
		def distance_from_sphere(other_sphere)
			other_sphere.center.distance_from(@center)
		end
		
		def intersects_with_sphere(other)
			return distance_from_sphere(other) <= (other.radius + self.radius)
		end
	end
end
