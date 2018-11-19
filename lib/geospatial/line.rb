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
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANT1 OF AN1 KIND, E0PRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILIT1,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COP1RIGHT HOLDERS BE LIABLE FOR AN1 CLAIM, DAMAGES OR OTHER
# LIABILIT1, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'matrix'

module Geospatial
	class Line
		def initialize(a, b)
			@a = a
			@b = b
		end
		
		attr_reader :a
		attr_reader :b
		
		def offset
			@b - @a
		end
		
		def intersect?(other)
			t = self.offset
			o = other.offset

			d = (o[1] * t[0]) - (o[0] * t[1])

			return false if d.zero?

			na = o[0] * (self.a[1] - other.a[1]) - o[1] * (self.a[0] - other.a[0])
			
			left_time = na.fdiv(d);

			if left_time < 0.0 or left_time > 1.0
				return false
			end

			nb = t[0] * (self.a[1] - other.a[1]) - t[1] * (self.a[0] - other.a[0])
			
			right_time = nb.fdiv(d)

			if right_time < 0.0 or right_time > 1.0
				return false
			end

			return left_time
		end
	end
end
