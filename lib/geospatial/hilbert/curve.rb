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
require_relative 'traverse'

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
				if block_given?
					self.class.traverse_recurse(@order, @rotation, 0, @origin, @size, &block)
				else
					self.class.to_enum(:traverse_recurse, @order, @rotation, 0, @origin, @size)
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
