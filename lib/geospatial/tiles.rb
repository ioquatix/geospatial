# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
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
	class Tiles
		# Radians to degrees multiplier
		R2D = (180.0 / Math::PI)
		D2R = (Math::PI / 180.0)
		
		def initialize(box, zoom = 5)
			@box = box
			@zoom = zoom
		end
		
		attr :box
		attr :zoom
		
		def map(longitude, latitude, zoom = @zoom)
			n = 2 ** zoom
			
			x = n * ((longitude + 180.0) / 360.0)
			y = n * (1.0 - (Math::log(Math::tan(latitude * D2R) + (1.0 / Math::cos(latitude * D2R))) / Math::PI)) / 2.0
			
			return x, y
		end
		
		def unmap(x, y, zoom = @zoom)
			n = 2 ** zoom
			longitude = x / n * 360.0 - 180.0
			latitude = Math::arctan(Math::sinh(Math::PI * (1.0 - 2.0 * y / n))) * R2D
			
			return longitude, latitude
		end
		
		def each(zoom = @zoom)
			return to_enum(:each, zoom) unless block_given?
			
			min = map(*@box.min, zoom)
			max = map(*@box.max, zoom)
			
			(min[0].floor...max[0].ceil).each do |x|
				# The y axis is reversed... (i.e. the origin is in the top left)
				(max[1].floor...min[1].ceil).each do |y|
					yield zoom, x, y
				end
			end
		end
	end
end
