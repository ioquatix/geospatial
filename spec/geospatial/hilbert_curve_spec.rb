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

require 'geospatial/location'
require 'geospatial/hilbert/curve'

RSpec.shared_examples_for "invertible function" do |input|
	it "should round-trip coordinates" do
		mapped = subject.map(input)
		output = subject.unmap(mapped)
		
		input.each_with_index do |value, index|
			expect(output[index]).to be_within(tolerance).of(value)
		end
	end
end

RSpec.shared_context "earth invertible curve" do
	it_behaves_like "invertible function", [-180, -90]
	it_behaves_like "invertible function", [0, 0]
	it_behaves_like "invertible function", [179, 89]
	
	it_behaves_like "invertible function", [170.53, -43.89]
end

RSpec.describe Geospatial::Hilbert::Curve.new(Geospatial::Dimensions.for_earth, 6) do
	let(:tolerance) {10.0}
	
	include_context "earth invertible curve"
end

RSpec.describe Geospatial::Hilbert::Curve.new(Geospatial::Dimensions.for_earth, 8) do
	let(:tolerance) {1.0}
	
	include_context "earth invertible curve"
end

RSpec.describe Geospatial::Hilbert::Curve.new(Geospatial::Dimensions.for_earth, 32) do
	let(:tolerance) {0.000001}
	
	include_context "earth invertible curve"
end
