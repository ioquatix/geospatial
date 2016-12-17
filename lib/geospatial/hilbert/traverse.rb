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

require_relative 'curve'

require 'pry'

module Geospatial
	module Hilbert
		class Curve
			def traverse(&block)
				return to_enum(:traverse) unless block_given?
				
				traverse_recurse(@order-1, 0, 0, self.origin, self.size, &block)
			end
			
			def bit_width
				@dimensions.count
			end
			
			# Traversal enumerates all regions of a curve, top-down.
			def traverse_recurse(order, mask, value, origin, size, &block)
				half_size = size.collect{|value| value * 0.5}.freeze
				prefix_mask = (1 << order) | mask
				
				(2**bit_width).times do |prefix|
					# These both do the same thing, not sure which one is faster:
					child_value = (value << @dimensions.count) | prefix
					prefix = child_value << (order*bit_width)
					
					index = HilbertIndex.from_integral(prefix, bit_width, @order).to_ordinal
					
					index = index & prefix_mask
					
					child_origin = @dimensions.unmap(index.axes).freeze
					
					# puts "yield(#{child_origin}, #{half_size}, #{prefix}, #{order})"
					# We avoid calling traverse_recurse simply to hit the callback on the leaf nodes:
					result = yield child_origin, half_size, prefix, order
					
					if order > 0 and result != :skip
						self.traverse_recurse(order - 1, prefix_mask, child_value, child_origin, half_size, &block)
					end
				end
			end
		end
	end
end
