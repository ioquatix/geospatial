#
# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# This file is part of the "geospatial" project and is released under the MIT license.
#

module Geospatial
	# This location is specifically relating to a WGS84 coordinate on Earth.
	class Histogram
		def initialize(bins, offset = 0, scale = 1)
			@bins = bins
			@offset = 0
			@scale = scale
		end
		
		attr :bins
		
		attr :offset
		attr :scale
		
		def add(value, amount = 1)
			index = Integer((value - @offset) / @scale)
			
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
	end
	
	class RadialHistogram < Histogram
		def initialize(center, offset = 0, scale = 360.0)
			super([0] * 360, offset, scale)
		end
		
		def add(point)
			
		end
	end
		
end
