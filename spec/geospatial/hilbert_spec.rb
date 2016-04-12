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

require 'geospatial/hilbert'
require_relative 'sorted'

module Geospatial::HilbertSpec
	describe Geospatial::Hilbert do
		it "base case should be identity" do
			# The base case for our coordinate system:
			expect(Geospatial::Hilbert.rotate(0, 0)).to be == 0
			expect(Geospatial::Hilbert.rotate(0, 1)).to be == 1
			expect(Geospatial::Hilbert.rotate(0, 2)).to be == 2
			expect(Geospatial::Hilbert.rotate(0, 3)).to be == 3
		end
		
		it "rotation is self-inverting" do
			4.times do |rotation|
				4.times do |quadrant|
					# rotate(rotation, rotate(rotation, quadrant)) == quadrant
					rotated = Geospatial::Hilbert.rotate(rotation, quadrant)
					expect(Geospatial::Hilbert.rotate(rotation, rotated)).to be == quadrant
				end
			end
		end
		
		it "computes the correct hash of order=0" do
			expect(Geospatial::Hilbert.hash(0, 0, 0)).to be == 0
			expect(Geospatial::Hilbert.hash(1, 0, 0)).to be == 1
			expect(Geospatial::Hilbert.hash(1, 1, 0)).to be == 2
			expect(Geospatial::Hilbert.hash(0, 1, 0)).to be == 3
		end
		
		it "computes the correct unhash" do
			expect(Geospatial::Hilbert.unhash(0, 0)).to be == [0, 0]
			expect(Geospatial::Hilbert.unhash(1, 0)).to be == [1, 0]
			expect(Geospatial::Hilbert.unhash(2, 0)).to be == [1, 1]
			expect(Geospatial::Hilbert.unhash(3, 0)).to be == [0, 1]
		end
		
		it "computes the correct hash of order=1" do
			expect(Geospatial::Hilbert.hash(0, 0, 1)).to be == 0
			expect(Geospatial::Hilbert.hash(0, 1, 1)).to be == 1
			expect(Geospatial::Hilbert.hash(1, 1, 1)).to be == 2
			expect(Geospatial::Hilbert.hash(1, 0, 1)).to be == 3
			
			expect(Geospatial::Hilbert.hash(2, 0, 1)).to be == 4
			expect(Geospatial::Hilbert.hash(3, 0, 1)).to be == 5
			expect(Geospatial::Hilbert.hash(3, 1, 1)).to be == 6
			expect(Geospatial::Hilbert.hash(2, 1, 1)).to be == 7
			
			expect(Geospatial::Hilbert.hash(2, 2, 1)).to be == 8
			expect(Geospatial::Hilbert.hash(3, 2, 1)).to be == 9
			expect(Geospatial::Hilbert.hash(3, 3, 1)).to be == 10
			expect(Geospatial::Hilbert.hash(2, 3, 1)).to be == 11
			
			expect(Geospatial::Hilbert.hash(1, 3, 1)).to be == 12
			expect(Geospatial::Hilbert.hash(1, 2, 1)).to be == 13
			expect(Geospatial::Hilbert.hash(0, 2, 1)).to be == 14
			expect(Geospatial::Hilbert.hash(0, 3, 1)).to be == 15
		end
		
		it "computes the correct unhash" do
			expect(Geospatial::Hilbert.unhash(12, 1)).to be == [1, 3]
		end
		
		it "traverses and generates all prefixes" do
			items = Geospatial::Hilbert.traverse(1, origin: [0, 0], size: [4, 4]).to_a
			
			# 4 items of order 1, 16 items of order 0.
			expect(items.size).to be == (4 + 16)
			
			expect(items[0]).to be == [[0, 0], [2, 2], 0b0000, 1]
			expect(items[1]).to be == [[0, 0], [1, 1], 0b0000, 0]
			expect(items[2]).to be == [[0, 1], [1, 1], 0b0001, 0]
			expect(items[3]).to be == [[1, 1], [1, 1], 0b0010, 0]
			expect(items[4]).to be == [[1, 0], [1, 1], 0b0011, 0]

			expect(items[5]).to be == [[2, 0], [2, 2], 0b0100, 1]
			expect(items[6]).to be == [[2, 0], [1, 1], 0b0100, 0]
			expect(items[7]).to be == [[3, 0], [1, 1], 0b0101, 0]
			expect(items[8]).to be == [[3, 1], [1, 1], 0b0110, 0]
			expect(items[9]).to be == [[2, 1], [1, 1], 0b0111, 0]
			
			expect(items[10]).to be == [[2, 2], [2, 2], 0b1000, 1]
			expect(items[11]).to be == [[2, 2], [1, 1], 0b1000, 0]
			expect(items[12]).to be == [[3, 2], [1, 1], 0b1001, 0]
			expect(items[13]).to be == [[3, 3], [1, 1], 0b1010, 0]
			expect(items[14]).to be == [[2, 3], [1, 1], 0b1011, 0]
			
			expect(items[15]).to be == [[0, 2], [2, 2], 0b1100, 1]
			expect(items[16]).to be == [[1, 3], [1, 1], 0b1100, 0]
			expect(items[17]).to be == [[1, 2], [1, 1], 0b1101, 0]
			expect(items[18]).to be == [[0, 2], [1, 1], 0b1110, 0]
			expect(items[19]).to be == [[0, 3], [1, 1], 0b1111, 0]
			
			prefixes = items.collect{|item| item[2]}
			expect(prefixes).to be_sorted
		end
		
		it "should generate same prefix" do
			expect(Geospatial::Hilbert.hash(4, 4, 2)) == Geospatial::Hilbert.hash(2, 2, 1)
		end
		
		it "traverses and generates valid matching hashes" do
			order = 4
			divisions = 2**(order+1)
			
			Geospatial::Hilbert.traverse(order, origin: [0, 0], size: [divisions, divisions]).each do |origin, size, prefix, depth|
				if depth == 0
					hash = Geospatial::Hilbert.hash(origin[0].to_i, origin[1].to_i, order) 
					# puts "Child origin=#{origin.inspect} prefix=#{prefix.to_s(2)} order=#{order} unhash=#{Geospatial::Hilbert.unhash(prefix)}"
					expect(prefix).to be == hash
				end
			end
		end
	end
end
