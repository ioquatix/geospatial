#
# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# This file is part of the "geospatial" project and is released under the MIT license.
#

require 'geospatial/histogram'

RSpec.describe Geospatial::Histogram do
	subject do
		described_class.new(min: -180, max: 180, scale: 10).tap do |histogram|
			histogram.bins = [0, 80, 540, 101, 29, 1880, 41, 23, 115, 715, 362, 244, 358, 955, 50, 53, 11, 7, 151, 43, 353, 1514, 2, 2, 0, 0, 0, 0, 0, 6, 155, 1737, 959, 1482, 110, 0]
		end
	end
	
	it "should generate appropriate peaks" do
		peaks = subject.peaks
		
		subject.bins.each_with_index do |v, i|
			d = subject.peaks.derivative[i]
			puts "#{i}, #{v}, #{d}"
		end
		
		peaks.each do |x, dx|
			puts "Peak at #{x}: #{dx}"
		end
		
		puts peaks.segments.to_a.inspect
	end
end
