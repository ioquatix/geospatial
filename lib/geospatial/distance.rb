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

module Geospatial
	# This location is specifically relating to a WGS84 coordinate on Earth.
	class Distance
		# Distance in meters:
		def initialize(value)
			@value = value
			@formatted_value = nil
		end
		
		def freeze
			formatted_value
			
			super
		end
		
		UNITS = ['m', 'km'].freeze
		
		def formatted_value
			unless @formatted_value
				scale = 0
				value = @value
				
				while value > 1000 and scale < UNITS.size
					value /= 1000.0
					scale += 1
				end
				
				@formatted_value = sprintf("%0.#{scale}f%s", value, UNITS.fetch(scale))
			end
			
			return @formatted_value
		end
		
		alias to_s formatted_value
		
		def to_f
			@value
		end
		
		def + other
			Distance.new(@value + other.to_f)
		end
		
		def - other
			Distance.new(@value - other.to_f)
		end
		
		def * other
			Distance.new(@value * other.to_f)
		end
		
		def / other
			Distance.new(@value / other.to_f)
		end
		
		def == other
			@value == other.to_f
		end
	end
end
