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

require 'geospatial/index'
require_relative 'sorted'

RSpec.shared_context "hilbert index" do
	it "computes the correct hash" do
		coordinates.each do |coordinate, encoded|
			index = Geospatial::OrdinalIndex.new(coordinate, bits)
			
			# puts "c: #{coordinate} i: #{index.inspect} h: #{index.to_hilbert.inspect} #{index.to_hilbert.to_i} == #{encoded}"
			
			expect(index.to_hilbert.to_i).to be == encoded
		end
	end
	
	it "computes the correct unhash" do
		coordinates.each do |coordinate, encoded|
			index = Geospatial::HilbertIndex.from_integral(encoded, coordinate.size, bits)
			
			expect(index.to_ordinal.axes).to be == coordinate
		end
	end
end

RSpec.describe "order=0 n=2" do
	let(:coordinates) {
		{
			#y, x
			[0, 0] => 0b00,
			[0, 1] => 0b01,
			[1, 1] => 0b10,
			[1, 0] => 0b11
		}
	}
	
	let(:bits) {1}
	
	it_behaves_like "hilbert index"
end

RSpec.describe "order=0 n=3" do
	let(:coordinates) {
		{
			# The sequence on the left walks through the hilbert curve in 3-space, while on the right is stepping incrementally through the curve.
			[0, 0, 0] => 0b000,
			[0, 0, 1] => 0b001,
			[0, 1, 1] => 0b010,
			[0, 1, 0] => 0b011,
			[1, 1, 0] => 0b100,
			[1, 1, 1] => 0b101,
			[1, 0, 1] => 0b110,
			[1, 0, 0] => 0b111,
		}
	}
	
	let(:bits) {1}
	
	it_behaves_like "hilbert index"
end

RSpec.describe "order=1 n=2" do
	# Curves of odd order, move on the most significant axis first (so that their top level motion is equivalent)
	let(:coordinates) {
		{
			# Lower left quadrant
			[0, 0] => 0b0000,
			[1, 0] => 0b0001,
			[1, 1] => 0b0010,
			[0, 1] => 0b0011,
			
			# Lower right quadrant
			[0, 2] => 0b0100,
			[0, 3] => 0b0101,
			[1, 3] => 0b0110,
			[1, 2] => 0b0111,
			
			# Upper right quadrant
			[2, 2] => 0b1000,
			[2, 3] => 0b1001,
			[3, 3] => 0b1010,
			[3, 2] => 0b1011,
			
			# Upper left quadrant
			[3, 1] => 0b1100,
			[2, 1] => 0b1101,
			[2, 0] => 0b1110,
			[3, 0] => 0b1111,
		}
	}
	
	let(:bits) {2}
	
	it_behaves_like "hilbert index"
end
