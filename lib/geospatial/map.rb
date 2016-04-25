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
	# A point is a location on a map with a specific hash representation based on the map. A point might store multi-dimenstional data (e.g. longitude, latitude, time) which is hashed to a single column.
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
		
		def eql?(other)
			self.class.eql?(other.class) and @coordinates.eql?(other.coordinates)
		end
		
		def hash
			@hash ||= @map.hash_for_coordinates(@coordinates).freeze
		end
	end
	
	class Map
		def self.for_earth
			self.new(Hilbert.new([LONGITUDE, LATITUDE]))
		end
		
		def initialize(function)
			@function = function
			
			@points = []
			
			@bounds = nil
		end
		
		def order
			@function.order
		end
		
		def bounds
			unless @bounds
				origin = @function.dimensions.collect(&:origin)
				size = @function.dimensions.collect(&:size)
				
				@bounds = Box.new(Vector[*origin], Vector[*size])
			end
			
			return @bounds
		end
		
		attr :points
		
		def hash_for_coordinates(coordinates)
			@function.map(coordinates)
		end
		
		def point_for_hash(hash)
			Point.new(self, @function.unmap(hash))
		end
		
		def point_for_coordinates(coordinates, object = nil)
			Point.new(self, coordinates, object)
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
			@function.traverse do |child_origin, child_size, prefix, order|
				child = Box.new(Vector[*child_origin], Vector[*child_size])
				
				# puts "Considering (order=#{order}) #{child.inspect}..."
				
				if region.intersect?(child)
					if order == depth # at bottom
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
		
		def filter_for(region, **options)
			filter = Filter.new
			
			traverse(region, **options) do |child, prefix, order|
				filter.add(prefix, order)
			end
			
			return filter
		end
	end
end
