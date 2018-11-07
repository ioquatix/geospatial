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

require 'geospatial/location'

RSpec.describe Geospatial::Location do
	context 'new zealand lakes' do
		let(:lake_tekapo) {Geospatial::Location.new(170.53, -43.89)}
		let(:lake_alex) {Geospatial::Location.new(170.45, -43.94)}
		
		it "should compute the correct distance between two points" do
			expect(lake_alex.distance_from(lake_tekapo)).to be_within(100).of(8_500)
		end
		
		it "should format nicely" do
			expect("#{lake_alex}").to be == "Geospatial::Location[170.45, -43.94]"
		end
	end
	
	context 'points on equator' do
		let(:west) {Geospatial::Location.new(-10, 0)}
		let(:east) {Geospatial::Location.new(10, 0)}
		
		it "should compute the bearing between two points" do
			expect(east.bearing_from(west)).to be_within(0.1).of(90)
		end
		
		it "should compute the bearing between two points" do
			expect(west.bearing_from(east)).to be_within(0.1).of(-90)
		end
	end
	
	context 'points on same latitude' do
		let(:north) {Geospatial::Location.new(0, 10)}
		let(:south) {Geospatial::Location.new(0, -10)}
		
		it "should compute the bearing between two points" do
			expect(north.bearing_from(south)).to be_within(0.1).of(0)
		end
		
		it "should compute the bearing between two points" do
			expect(south.bearing_from(north)).to be_within(0.1).of(180)
		end
	end
end

require 'bigdecimal'

RSpec.describe Geospatial::Location[BigDecimal.new("170.45"), BigDecimal.new("-43.94")] do
	it "should format nicely" do
		expect("#{subject}").to be == "Geospatial::Location[170.45, -43.94]"
	end
end