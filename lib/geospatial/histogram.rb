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
		
		def add(value, amount = 1)
			index = ((value - @min) / @scale).floor
			
			if @bins[index]
				@bins[index] += amount
			else
				@bins[index] = amount
			end
			
			return self
		end
		
		def peaks
			@bins.each_with_index
		end
		
		def offset(index)
			@min + (index * @scale)
		end
		
		def inspect
			buffer = String.new("\#<#{self.class}")
			
			@bins.each_with_index do |bin, index|
				buffer << "\n#{offset(index).to_s.rjust(8)}: #{bin}"
			end
			
			buffer << "\n>"
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
