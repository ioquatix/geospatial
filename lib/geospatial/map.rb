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

require_relative 'hilbert/curve'

module Geospatial
	# A point is a location on a map with a specific hash representation based on the map. A point might store multi-dimentional data (e.g. longitude, latitude, time) which is hashed to a single column.
	class Point
		def initialize(map, coordinates, object = nil)
			@map = map
			@coordinates = coordinates
			@object = object
		end
		
		attr :object
		
		def [] index
			@coordinates[index]
		end
		
		def []= index, value
			@coordinates[index] = value
		end
		
		attr :coordinates
		
		alias to_a coordinates
		
		def eql?(other)
			self.class.eql?(other.class) and @coordinates.eql?(other.coordinates)
		end
		
		def hash
			@hash ||= @map.hash_for_coordinates(@coordinates).freeze
		end
	end
	
	class Map
		def self.for_earth(order = 20)
			self.new(Hilbert::Curve.new(Dimensions.for_earth, order))
		end
		
		def initialize(curve)
			@curve = curve
			@points = []
			@bounds = nil
		end
		
		attr :curve
		
		def order
			@curve.order
		end
		
		def bounds
			unless @bounds
				origin = @curve.origin
				size = @curve.size
				
				@bounds = Box.new(origin, size)
			end
			
			return @bounds
		end
		
		attr :points
		
		def hash_for_coordinates(coordinates)
			@curve.map(coordinates)
		end
		
		def point_for_hash(hash)
			Point.new(self, @curve.unmap(hash))
		end
		
		def point_for_coordinates(coordinates, object = nil)
			Point.new(self, coordinates, object)
		end
		
		def point_for_object(object)
			Point.new(self, object.to_a, object)
		end
		
		def << object
			@points << point_for_coordinates(object.to_a, object)
			
			return self
		end
		
		def count
			@points.count
		end
		
		def sort!
			@points.sort_by!(&:hash)
		end
		
		def query(region, **options)
			filter = filter_for(region, **options)
			
			return filter.apply(@points).map(&:object)
		end
		
		def traverse(region, depth: 0)
			@curve.traverse do |child_origin, child_size, prefix, order|
				child = Box.new(Vector.elements(child_origin), Vector.elements(child_size))
				
				# puts "Considering (order=#{order}) #{child.inspect}..."
				
				if region.intersect?(child)
					if order == depth # at bottom
						# puts "at bottom -> found prefix #{prefix.to_s(2)} (#{child.inspect})"
						yield(child, prefix, order); :skip
					elsif region.include?(child)
						# puts "include child -> found prefix #{prefix.to_s(2)} (#{child.inspect})"
						yield(child, prefix, order); :skip
					else
						# puts "going deeper..."
					end
				else
					# puts "out of bounds."
					:skip
				end
			end
		end
		
		def filter_for(*regions, **options)
			filter = Filter.new(@curve)
			
			regions.each do |region|
				# The filter will coalesce sequential segments of the curve into a single range.
				traverse(region, **options) do |child, prefix, order|
					filter.add(prefix, order)
				end
			end
			
			return filter
		end
	end
end
