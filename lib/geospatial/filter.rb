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
	class Filter
		class Range
			def initialize(prefix, order)
				@min = prefix
				update_max(prefix, order)
			end
			
			attr :min
			attr :max
			
			def to_s
				"#{min.to_s(2)}..#{max.to_s(2)}"
			end
			
			# Returns the new max if expansion was possible, or nil otherwise.
			def expand!(prefix, order)
				if @max < prefix and prefix == @max+1
					update_max(prefix, order)
				end
			end
			
			def include?(hash)
				hash >= min and hash <= max
			end
			
			private
			
			def update_max(prefix, order)
				# We set the RHS of the prefix to 1s, which is the maximum:
				@max = prefix | ((1 << (order*2)) - 1)
			end
		end
		
		def initialize(curve)
			@ranges = []
			@curve = curve
		end
		
		attr :ranges
		
		def add(prefix, order)
			if last = @ranges.last
				raise ArgumentError.new("Cannot add non-sequential prefix") unless prefix > last.max
			end
			
			unless last = @ranges.last and last.expand!(prefix, order)
				@ranges << Range.new(prefix, order)
			end
		end
		
		def apply(points)
			# This is a poor implementation.
			points.select{|point| @ranges.any?{|range| range.include?(point.hash)}}
		end
		
		alias & apply
		
		def include?(point)
			@ranges.any?{|range| range.include?(point.hash)}
		end
		
		def each(depth: 0)
			# TODO using a range tree might allow a significantly improved implementation.
			@curve.traverse do |child_origin, child_size, prefix, order|
				child = Box.new(Vector.elements(child_origin), Vector.elements(child_size))
				
				# puts "Considering (order=#{order}) #{child.inspect}..."
				
				min = prefix
				max = prefix | ((1 << (order*2)) - 1)
				
				if min_range = find(min)
					if order == depth # at bottom
						yield(child, prefix, order); :skip
					elsif min_range.include?(max)
						# This range completely contains the current prefix/order
						yield(child, prefix, order); :skip
					else
						# go deeper
					end
				elsif max_range = find(max)
					if order == depth # at bottom
						yield(child, prefix, order); :skip
					else
						# go deeper
					end
				elsif sub_range = @ranges.find{|range| range.min >= min && range.max <= max}
					# go deeper
				else
					:skip # out of bounds
				end
			end
		end
		
		def find(hash)
			@ranges.find{|range| range.include?(hash)}
		end
	end
end
