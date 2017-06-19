
require 'geospatial/hilbert/curve'

require_relative 'sorted'

RSpec.describe Geospatial::Hilbert::Curve do
	let(:dimensions) {Geospatial::Dimensions.from_ranges(0..4, 0..4)}
	subject {Geospatial::Hilbert::Curve.new(dimensions, 2)}
	
	it "traverses and generates all prefixes" do
		items = subject.traverse.to_a
		
		# 4 items of order 1, 16 items of order 0.
		expect(items.size).to be == (4 + 16)
		
		expect(items[0]).to be == [[0, 0], [2, 2], 0b0000, 1]
		expect(items[1]).to be == [[0, 0], [1, 1], 0b0000, 0]
		expect(items[2]).to be == [[1, 0], [1, 1], 0b0001, 0]
		expect(items[3]).to be == [[1, 1], [1, 1], 0b0010, 0]
		expect(items[4]).to be == [[0, 1], [1, 1], 0b0011, 0]

		expect(items[5]).to be == [[0, 2], [2, 2], 0b0100, 1]
		expect(items[6]).to be == [[0, 2], [1, 1], 0b0100, 0]
		expect(items[7]).to be == [[0, 3], [1, 1], 0b0101, 0]
		expect(items[8]).to be == [[1, 3], [1, 1], 0b0110, 0]
		expect(items[9]).to be == [[1, 2], [1, 1], 0b0111, 0]
		
		expect(items[10]).to be == [[2, 2], [2, 2], 0b1000, 1]
		expect(items[11]).to be == [[2, 2], [1, 1], 0b1000, 0]
		expect(items[12]).to be == [[2, 3], [1, 1], 0b1001, 0]
		expect(items[13]).to be == [[3, 3], [1, 1], 0b1010, 0]
		expect(items[14]).to be == [[3, 2], [1, 1], 0b1011, 0]
		
		# This result here might seem a bit unexpected, but it's correct. For a 2-dimentional curve, the origin of the quadrant isn't always the same as the origin of the curve in that region. If you draw a 2D curve of order 2, you will see that the origin of the first 3 sub-curves is in the bottom left, but the last sub-curve has it's origin in the top right.
		expect(items[15]).to be == [[2, 0], [2, 2], 0b1100, 1]
		expect(items[16]).to be == [[3, 1], [1, 1], 0b1100, 0]
		expect(items[17]).to be == [[2, 1], [1, 1], 0b1101, 0]
		expect(items[18]).to be == [[2, 0], [1, 1], 0b1110, 0]
		expect(items[19]).to be == [[3, 0], [1, 1], 0b1111, 0]
		
		prefixes = items.collect{|item| item[2]}
		expect(prefixes).to be_sorted
	end
end

RSpec.describe Geospatial::Hilbert::Curve do
	let(:order) {4}
	let(:divisions) {2**order}
	let(:dimensions) {Geospatial::Dimensions.from_ranges(0..divisions, 0..divisions)}
	subject {Geospatial::Hilbert::Curve.new(dimensions, order)}
	
	it "traverses and generates valid matching hashes" do
		subject.traverse do |origin, size, prefix, depth|
			if depth == 0
				index = Geospatial::OrdinalIndex.new(origin.collect(&:to_i), order).to_hilbert
				
				# puts "Child origin=#{origin.inspect} prefix=#{prefix.to_s(2)} order=#{order}"
				
				expect(prefix).to be == index.to_i
			end
		end
	end
end