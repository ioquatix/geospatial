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

require 'geospatial/map'

module Geospatial::AlignedBoxSpec
	describe Geospatial::AlignedBox do
		let(:square) {Geospatial::AlignedBox.new(Vector[-1, -1], Vector[2, 2])}
		
		it "compute integral points" do
			expect(square.integral_offset([-1, -1], [4, 4])).to be == [0, 0]
		end
		
		let(:new_zealand) {Geospatial::AlignedBox.from_bounds(Vector[166.0, -48.0], Vector[180.0, -34.0])}
		let(:child) {Geospatial::AlignedBox.new(Vector[135.0, -67.5], Vector[45.0, 22.5])}
		
		it "should intersect" do
			expect(new_zealand).to be_intersect(child)
		end
	end
end
