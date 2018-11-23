#
# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# This file is part of the "geospatial" project and is released under the MIT license.
#

module Geospatial
	# This location is specifically relating to a WGS84 coordinate on Earth.
	class Histogram
		def initialize(min: 0, max: 1, scale: 0.1, items: true)
			@min = min
			@max = max
			@scale = scale
			
			@count = 0
			
			if items
				@items = Hash.new{|h,k| h[k] = Array.new}
			end
			
			@size = ((@max - @min) / @scale).ceil
			@bins = [0] * @size
			@offset = 0
			@scale = scale
		end
		
		attr :bins
		attr :items
		
		attr :count
		
		attr :offset
		attr :scale
		
		def bins= bins
			raise ArgumentError, "Incorrect length" unless bins.size == @size
			
			@bins = bins
		end
		
		def [] index
			@bins[index]
		end
		
		def size
			@bins.size
		end
		
		def map(value)
			((value - @min) / @scale)
		end
		
		def unmap(index)
			@min + (index * @scale)
		end
		
		def add(value, amount = 1, item: nil)
			index = map(value).floor % @size
			
			if !block_given? or yield(index, value)
				@count += 1
				@bins[index] += amount
				
				if @items and item
					@items[index] << item
				end
			end
			
			return index
		end
		
		def inspect
			buffer = String.new("\#<#{self.class}")
			
			@bins.each_with_index do |bin, index|
				buffer << " #{unmap(index)}: #{bin}"
			end
			
			buffer << ">"
		end
		
		def each
			return to_enum unless block_given?
			
			@bins.each_with_index do |value, index|
				yield unmap(index), value
			end
		end
		
		def peaks
			Peaks.new(self)
		end
	end
	
	class RadialHistogram < Histogram
		def initialize(center, min: -180, max: 180, scale: 1)
			super(min: min, max: max, scale: scale)
			
			@center = center
		end
		
		def add(point, value = 1)
			super(point.bearing_from(@center), value)
		end
	end
	
	class Peaks
		include Enumerable
		
		def initialize(values)
			@values = values
			@derivative = []
			
			s = @values.size
			
			@values.size.times do |i|
				# Apply the Laplacian of Gaussians to compute the gradient changes:
				# @derivative << (@values[i-2] * -1) + (@values[i-1] * -1) + (@values[i] * 4) + (@values[i+1-s] * -1) + (@values[i+2-s] * -1)
				@derivative << (2.0 * @values[i-1]) + (-2.0 * @values[i+1-s])
			end
		end
		
		attr :derivative
		
		def each
			return to_enum unless block_given?
			
			@derivative.each_with_index do |y2, x2|
				x1 = x2 - 1
				y1 = @derivative[x1]
				
				if (y1 <= 0 and y2 > 0) or (y1 > 0 and y2 <= 0)
					# There has been a zero crossing, so we have a peak somewhere here:
					g = (y2.to_f - y1.to_f)
					m = (-y1.to_f / g)
					
					yield x1 + m, g
				end
			end
		end
		
		def peaks
			self.class.new(@derivative)
		end
		
		def segments
			return to_enum(:segments) unless block_given?
			
			peaks = self.peaks
			gradients = peaks.to_a
			
			return if gradients.empty?
			
			index, gradient = gradients.first
			
			if gradient > 0
				gradients.push gradients.shift
			end
			
			gradients.each_slice(2) do |up, down|
				yield up, down
			end
		end
	end
end
