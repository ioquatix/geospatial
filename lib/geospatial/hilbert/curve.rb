# Copyright, 2015, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative '../dimensions'
require_relative '../index'

module Geospatial
	module Hilbert
		class Curve
			def initialize(dimensions, order = 30)
				raise ArgumentError("Order #{order} must be positive integer!") unless order >= 1
				
				# Order is the number of levels of the curve, which is equivalent to the number of bits per dimension.
				@order = order
				@scale = 2**@order
				
				@dimensions = dimensions * @scale
				@origin = dimensions.origin
				@size = dimensions.size
			end
			
			attr :order
			attr :scale
			attr :dimensions
			
			def origin
				@dimensions.origin
			end
			
			def size
				@dimensions.size
			end
			
			def to_s
				"\#<#{self.class} order=#{@order} dimensions=#{@dimensions}>"
			end
			
			# This is a helper entry point for traversing Hilbert space.
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
			
			def map(coordinates)
				axes = @dimensions.map(coordinates).map(&:floor)
				
				index = OrdinalIndex.new(axes, @order)
				
				return index.to_hilbert.to_i
			end
			
			def unmap(value)
				index = HilbertIndex.from_integral(value, @dimensions.count, @order)
				
				return @dimensions.unmap(index.to_ordinal.axes)
			end
		end
	end
end
