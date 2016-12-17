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

require 'matrix'

module Geospatial
	# An integral dimension which maps a continuous space into an integral space. The scale is the maximum integral unit.
	class Dimension
		def initialize(origin, size, scale = 1.0)
			@origin = origin
			@size = size
			@scale = scale
		end
		
		def to_s
			if @scale != 1.0
				"(#{min}..#{max} * #{@scale})"
			else
				"(#{min}..#{max})"
			end
		end
		
		def * factor
			self.class.new(@origin, @size, @scale * factor)
		end
		
		attr :origin
		attr :size
		attr :scale
		
		def min
			@origin
		end
		
		def max
			@origin + @size
		end
		
		# Normalize the value into the range 0..1 and then multiply by scale.
		def map(value)
			((value - @origin).to_f / @size) * @scale
		end
		
		def unmap(value)
			@origin + (value / @scale) * @size
		end
	end
	
	class Dimensions
		def initialize(dimensions)
			@dimensions = dimensions
		end
		
		attr :dimensions
		
		def to_s
			"[#{@dimensions.join(', ')}]"
		end
		
		def freeze
			@dimensions.freeze
			
			super
		end
		
		def count
			return @dimensions.count
		end
		
		def * factor
			self.class.new(@dimensions.collect{|dimension| dimension * factor})
		end
		
		def origin
			@dimensions.collect(&:origin)
		end
		
		def size
			@dimensions.collect(&:size)
		end
		
		def scale
			@dimensions.colect(&:scale)
		end
		
		def min
			@dimensions.collect(&:min)
		end
		
		def max
			@dimensions.collect(&:max)
		end
		
		def map(values)
			@dimensions.zip(values).collect{|d,v| d.map(v)}
		end
		
		def unmap(values)
			@dimensions.zip(values).collect{|d,v| d.unmap(v)}
		end
		
		LATITUDE = Dimension.new(-90.0, 180.0).freeze
		LONGITUDE = Dimension.new(-180.0, 360.0).freeze
		
		def self.for_earth
			@for_earth ||= self.new([LONGITUDE, LATITUDE]).freeze
		end
		
		def self.from_ranges(*ranges)
			self.new ranges.collect{|range| Dimension.new(range.min, range.max - range.min)}
		end
	end
end
