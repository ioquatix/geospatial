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

require_relative 'location'
require_relative 'aligned_box'

module Geospatial
	class Map
		# Will use 60 bits to store hash:
		ORDER = 30
		
		class Point
			def initialize(map, location)
				@map = map
				@location = location
			end
			
			attr :location
			
			def hash
				@hash ||= @map.location_hash(@location).freeze
			end
		end
		
		EARTH_BOUNDS = AlignedBox.new(Vector[-180, -90], Vector[180, 90]).freeze
		
		def initialize(bounds = EARTH_BOUNDS, order: ORDER)
			@order = order
			@scale = ([2**@order] * 2).freeze
			
			@bounds = bounds
			
			@points = []
		end
		
		attr :points
		
		def location_hash(location)
			coordinates = @bounds.integral_offset(location.to_a, @scale)
			
			return Hilbert.hash(*coordinates, @order)
		end
		
		def << location
			@points << Point.new(self, location)
		end
		
		def count
			@points.count
		end
		
		def sort!
			@points.sort_by!(&:hash)
		end
		
		def query(bounding_box)
			ranges = []
			
			Hilbert.traverse(ORDER, origin: @bounds.origin, size: @bounds.size) do |child_origin, child_size, prefix, order|
				child = AlignedBox.new(child_origin, child_size)
				
				if bounding_box.overlaps(child)
				end
			end
		end
	end
end
