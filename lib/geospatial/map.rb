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
require_relative 'box'
require_relative 'filter'
require_relative 'hilbert'

module Geospatial
	class Map
		# The order is the number of times to divide along each axis, i.e. 2**(order+1) discrete segments. Each division requires 2 bits, one for each longitude/latitude. Order 0 gives 4 segments in total.
		DEFAULT_ORDER = 11
		
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
		
		EARTH_BOUNDS = Box.new(Vector[-180, -90], Vector[360, 180]).freeze
		
		def initialize(bounds = EARTH_BOUNDS, order: DEFAULT_ORDER)
			raise ArgumentError("Order #{order} must be positive integer!") unless order >= 1
			
			@order = order
			@scale = 2**(order+1)
			
			@bounds = bounds
			
			@points = []
		end
		
		attr :order
		attr :bounds
		attr :points
		
		def location_hash(location)
			coordinates = @bounds.integral_offset(location.to_a, @scale)
			
			return Hilbert.hash(*coordinates, @order)
		end
		
		def << location
			@points << Point.new(self, location)
			
			return self
		end
		
		def count
			@points.count
		end
		
		def sort!
			@points.sort_by!(&:hash)
		end
		
		def query(region)
			filter = filter_for(region)
			
			return filter.apply(@points).map(&:location)
		end
		
		def traverse(region)
			Hilbert.traverse(@order, origin: @bounds.origin, size: @bounds.size) do |child_origin, child_size, prefix, order|
				child = Box.new(Vector[*child_origin], Vector[*child_size])
				
				# puts "Considering (order=#{order}) #{child.inspect}..."
				
				if region.intersect?(child)
					if order == 0 # at bottom
						# puts "at bottom -> found prefix #{prefix.to_s(2)} (#{child.inspect})"
						yield(child, prefix, order); :skip
					elsif region.include?(child)
						#puts "include child -> found prefix #{prefix.to_s(2)} (#{child.inspect})"
						yield(child, prefix, order); :skip
					else
						#puts "going deeper..."
					end
				else
					#puts "out of bounds."
					:skip
				end
			end
		end
		
		def filter_for(region)
			filter = Filter.new
			
			traverse(region) do |child, prefix, order|
				filter.add(prefix, order)
			end
			
			return filter
		end
	end
end
