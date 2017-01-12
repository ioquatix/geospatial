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

require 'geospatial/distance'

RSpec.describe Geospatial::Distance.new(10000) do
	it "should have correct value" do
		expect(subject.to_f).to be == 10000.0
	end
	
	it "should format string" do
		expect(subject.to_s).to be == "10.0km"
	end
	
	it "can divide distances" do
		expect(subject / 2).to be == 5000.0
	end
	
	it "can multiply distances" do
		expect(subject * 2).to be == 20000.0
	end
	
	it "can add distances" do
		expect(subject + 100).to be == 10100.0
	end
	
	it "can subtract distances" do
		expect(subject - 100).to be == 9900.0
	end
	
	it "can sort distances" do
		expect([subject, subject*2, subject*3].min).to be == subject
		expect([subject, subject*2, subject*3].max).to be == (subject*3)
	end
end
