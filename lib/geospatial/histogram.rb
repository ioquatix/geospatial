#
# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# This file is part of the "geospatial" project and is released under the MIT license.
#

module Geospatial
	# This location is specifically relating to a WGS84 coordinate on Earth.
	class Histogram
		def initialize(min = 0, max = 1, scale = 0.1)
			@min = min
			@max = max
			@scale = scale
			
			@count = ((@max - @min) / @scale).ceil
			@bins = [0] * @count
			@offset = 0
			@scale = scale
		end
		
		attr :bins
		
		attr :offset
		attr :scale
		
		def map(value)
			((value - @min) / @scale)
		end
		
		def unmap(index)
			@min + ((index + 0.5) * @scale)
		end
		
		def add(value, amount = 1)
			index = map(value).floor
			
			if @bins[index]
				@bins[index] += amount
			else
				@bins[index] = amount
			end
			
			return self
		end
		
		def inspect
			buffer = String.new("\#<#{self.class}")
			
			@bins.each_with_index do |bin, index|
				buffer << "\n#{unmap(index).to_s.rjust(8)}: #{bin}"
			end
			
			buffer << "\n>"
		end
		
		def each
			return to_enum unless block_given?
			
			@bins.each_with_index do |value, index|
				yield unmap(index), value
			end
		end
	end
	
	class RadialHistogram < Histogram
		def initialize(center, min = -180, max = 180, scale = 10)
			super(min, max, scale)
			
			@center = center
		end
		
		def add(point, value = 1)
			super(point.bearing_from(@center), value)
		end
	end
end
