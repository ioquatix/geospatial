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
	module Interleave
		# Convert a Tranpose Hilbert index into a Hilbert integer
		# 15-bit Hilbert integer = A B C D E F G H I J K L M N O is stored
		# as its Transpose:
		# x[0] = A D G J M
		# x[1] = B E H K N
		# x[2] = C F I L O
		#        |--bits-|
		def self.map(index, bits)
			result = 0
			
			index.each_with_index do |x, i|
				offset = index.size - (i+1)
				
				bits.times do |j|
					result |= (x & 1) << (j*index.size+offset)
					
					x >>= 1
					
					break if x == 0
				end
			end
			
			return result
		end
		
		def self.unmap(integral, width)
			result = [0] * width
			mask = (1 << width) - 1
			offset = 0
			
			while integral != 0
				# N times, look at each bit and append
				width.times do |i|
					bit = (integral >> i) & 1
					result[-1-i] |= bit << offset
				end
				
				# Pop first n bits
				integral >>= width
				
				offset += 1
			end
			
			return result
		end
	end
end
