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
	module Hilbert
		# Convert between Hilbert index and N-dimensional points.
		# 
		# The Hilbert index is expressed as an array of transposed bits.
		# 
		# Example: 5 bits for each of n=3 coordinates.
		# 15-bit Hilbert integer = A B C D E F G H I J K L M N O is stored
		# as its Transpose                        ^
		# X[0] = A D G J M                    X[2]|  7
		# X[1] = B E H K N        <------->       | /X[1]
		# X[2] = C F I L O                   axes |/
		#        high low                         0------> X[0]
		#
		# This algorithm is derived from work done by John Skilling and published in "Programming the Hilbert curve".
		
		# Convert the Hilbert index into an N-dimensional point expressed as a vector of uints.
		# @param transposed_index The Hilbert index stored in transposed form.
		# @param bits Number of bits per coordinate.
		# @return Coordinate vector.
		def self.unmap(transposed_index, bits)
			x = transposed_index.dup #var X = (uint[])transposedIndex.Clone();
			n = x.length # n: Number of dimensions
			m = 1 << bits
			
			# Gray decode by H ^ (H/2)
			t = x[n-1] >> 1 # t = X[n - 1] >> 1;
			
			(n-1).downto(1) {|i| x[i] ^= x[i-1]}
			x[0] ^= t
			
			# Undo excess work
			q = 2
			while q != m
				p = q - 1
				
				i = n - 1
				while i >= 0
					if x[i] & q != 0
						x[0] ^= p # invert
					else
						t = (x[0] ^ x[i]) & p;
						x[0] ^= t;
						x[i] ^= t;
					end
					
					i -= 1
				end

				q <<= 1
			end
			
			return x
		end
		
		# Given the coordinates of a point in N-Dimensional space, find the distance to that point along the Hilbert curve.
		# That distance will be transposed; broken into pieces and distributed into an array.
		# 
		# The number of dimensions is the length of the hilbert_index array.
		# @param hilbert_index Point in N-space.
		# @param bits Depth of the Hilbert curve. If bits is one, this is the top-level Hilbert curve.
		# @return The Hilbert distance (or index) as a transposed Hilbert index.
		def self.map(hilbert_axes, bits)
			x = hilbert_axes.dup
			n = x.length # n: Number of dimensions
			m = 1 << (bits - 1)
			
			# Inverse undo
			q = m
			while q > 1
				p = q - 1
				i = 0
				
				while i < n
					if (x[i] & q) != 0
							x[0] ^= p # invert
					else
						t = (x[0] ^ x[i]) & p;
						x[0] ^= t;
						x[i] ^= t;
					end
					
					i += 1
				end
				
				q >>= 1
			end # exchange
			
			# Gray encode
			1.upto(n-1) {|i| x[i] ^= x[i-1]}
			
			t = 0
			q = m
			while q > 1
				if x[n-1] & q != 0
					t ^= q - 1
				end
				
				q >>= 1
			end
			
			0.upto(n-1) {|i| x[i] ^= t}
			
			return x
		end
	end
end
