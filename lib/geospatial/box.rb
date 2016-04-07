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
		def self.from_bounds(min, max)
			self.new(min, max-min, max)
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
		
		def dimensions
			@origin.size
		end
		
		attr :origin
		attr :size
		
		def inspect
			"#{self.class}(#{min.inspect} -> #{max.inspect})"
		end
		
		def min
			@origin
		end
		
		def max
			@max ||= @origin + @size
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
	end
end
