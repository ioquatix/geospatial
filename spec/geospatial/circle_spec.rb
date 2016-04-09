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

require 'geospatial/circle'
require 'geospatial/map'
require 'prawn'

module Geospatial::CircleSpec
	describe Geospatial::Circle do
		let(:lake_tekapo) {Geospatial::Location.new(170.53, -43.89)}
		let(:lake_alex) {Geospatial::Location.new(170.45, -43.94)}
		let(:sydney) {Geospatial::Location.new(151.21, -33.85)}
		
		let(:new_zealand) {Geospatial::Box.from_bounds(Vector[166.0, -48.0], Vector[180.0, -34.0])}
		let(:australia) {Geospatial::Box.from_bounds(Vector[112.0, -45.0], Vector[155.0, -10.0])}
		
		let(:circle_lake_tekapo) {Geospatial::Circle.new(lake_tekapo, 10_000)}
		let(:circle_lake_alex) {Geospatial::Circle.new(lake_tekapo, 10_000)}
		let(:circle_sydney) {Geospatial::Circle.new(sydney, 10_000)}
		let(:circle_new_zealand) {Geospatial::Circle.new(lake_tekapo, 1_000_000)}
		
		it "should intersect circles" do
			expect(circle_lake_tekapo).to be_intersect(circle_lake_alex)
		end
		
		it "should not intersect distant circles" do
			expect(circle_lake_tekapo).to_not be_intersect(circle_sydney)
		end
		
		it "should include circles" do
			expect(circle_new_zealand).to be_include(circle_lake_tekapo)
			expect(circle_new_zealand).to be_include(circle_lake_alex)
		end
		
		it "should not include distant circles" do
			expect(circle_new_zealand).to_not be_include(circle_sydney)
		end
		
		def visualise(map)
			margin = 10
			size = map.bounds.size.to_a
			half_size = size.map{|i| i.to_f / 2}
			origin = [size[0] / 2, size[1] / 2]
			
			pdf = Prawn::Document.new(
				page_size: [size[0] + 40, size[1] + 40],
				margin: 20,
			)
			
			pdf.line_width 0.1
			
			world_path = File.expand_path("world.png", __dir__)
			pdf.image world_path, :at => [0, 180], width: 360, height: 180
			
			pdf.stroke_axis(step_length: 45)
			
			pdf.transparent(0.3, 0.9) do
				pdf.stroke_color "000000"
				pdf.fill_color "00abcc"
				
				yield pdf, Vector[*origin]
			
				pdf.fill_color "00ff00"
				
				map.points.each do |point|
					center =  [origin[0] + point.location.longitude, origin[1] + point.location.latitude]
					pdf.circle center, 0.1
				end
				
				pdf.fill
			end
			
			pdf.render_file "circle.pdf"
		end
		
		it "can generate visualisation" do
			map = Geospatial::Map.new
			
			map << lake_tekapo
			
			circle = Geospatial::Circle.new(lake_tekapo, 100_000)
			
			filter = map.filter_for(circle)
			#puts filter.ranges.inspect
			#puts filter.ranges.count
			
			visualise(map) do |pdf, origin|
				#count = 0
				map.traverse(circle) do |child, prefix, order|
					#count += 1
					size = child.size
					top_left = (origin + child.min) + Vector[0, size[1]]
					pdf.rectangle(top_left.to_a, *size.to_a)
					# puts "#{top_left.to_a} #{size.to_a}"
				end
				
				#puts "count=#{count}"
				
				pdf.fill_and_stroke
			end
		end
	end
end
