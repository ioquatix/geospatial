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

module Geospatial::MapSpec
	describe Geospatial::Map do
		let(:lake_tekapo) {Geospatial::Location.new(170.53, -43.89)}
		let(:lake_alex) {Geospatial::Location.new(170.45, -43.94)}
		let(:sydney) {Geospatial::Location.new(151.21, -33.85)}
		
		let(:new_zealand) {Geospatial::AlignedBox.from_bounds(Vector[166.0, -48.0], Vector[180.0, -34.0])}
		let(:australia) {Geospatial::AlignedBox.from_bounds(Vector[112.0, -45.0], Vector[155.0, -10.0])}

		it "should add points" do
			subject << lake_tekapo
			subject << lake_alex
			
			subject.sort!
			
			expect(subject.count).to be == 2
			expect(subject.points[0].hash).to be <= subject.points[1].hash
		end
		
		it "should find points in New Zealand" do
			subject << lake_tekapo << lake_alex << sydney
			
			subject.sort!
			
			points = subject.query(new_zealand)
			expect(points).to include(lake_tekapo, lake_alex)
			expect(points).to_not include(syndney)
		end
	end
end
