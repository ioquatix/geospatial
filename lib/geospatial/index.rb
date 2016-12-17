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

require_relative 'interleave'
require_relative 'hilbert'

module Geospatial
	# This class represents a n-dimentional index.
	# @param axes Point in n-space, e.g. [3, 7].
	# @param bits Number of bits to use for each axis, e.g. 8.
	class Index
		def initialize(axes, bits)
			@axes = axes
			@bits = bits
		end
		
		def self.from_integral(integral, width, bits)
			self.new(Interleave.unmap(integral, width), bits)
		end
		
		attr :axes
		attr :bits
		
		def & mask
			self.class.new(axes.collect{|axis| axis & mask}, @bits)
		end
		
		def hash
			@axes.hash
		end
		
		def eql?(other)
			self.class.eql?(other.class) and @axes.eql?(other.axes) and @bits.eql?(other.bits)
		end
		
		def to_i
			Interleave.map(@axes, @bits)
		end
		
		def bit_length
			@axes.size * @bits
		end
		
		def inspect
			i = self.to_i
			"\#<#{self.class}[#{@bits}] 0b#{i.to_s(2).rjust(bit_length, '0')} (#{i}) #{@axes.inspect}>"
		end
	end
	
	# Represents an index on the hilbert curve.
	class HilbertIndex < Index
		def to_ordinal
			OrdinalIndex.new(Hilbert.unmap(@axes, @bits), @bits)
		end
	end
	
	# Represents an index in ordinal space.
	class OrdinalIndex < Index
		def to_hilbert
			HilbertIndex.new(Hilbert.map(@axes, @bits), @bits)
		end
	end
end
