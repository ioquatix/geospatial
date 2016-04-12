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

module Geospatial::IndexSpec
	describe Geospatial::Index do
		let(:lake_alex) {Geospatial::Location.new(170.45, -43.94)}
		let(:point) {Geospatial::Index.map.point_for_location(lake_alex)}
		
		it "should dump to hash" do
			expect(Geospatial::Index.dump(point)).to be == point.hash
		end
		
		it "should load hash" do
			truncated_point = Geospatial::Index.load(point.hash)
			distance = truncated_point.location.distance_from(point.location)
			
			# The distance between the truncated point and the original point should be < 10 meters.
			expect(distance).to be < 10
		end
	end
end
