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

require 'geospatial/polygon'

require 'geospatial/map'
require 'prawn'

RSpec.shared_context "kaikoura region" do
	let(:region) do
		Geospatial::Polygon[
			Vector[173.7218528654108, -42.32817252073923],
			Vector[173.6307775307161, -42.32729039137249],
			Vector[173.5400659958715, -42.39758413896335],
			Vector[173.5446498680837, -42.43847509799515],
			Vector[173.6833471779081, -42.44870319335309],
			Vector[173.7608096128163, -42.42144813099029],
			Vector[173.7218528654108, -42.32817252073923],
		]
	end
	
	let(:filter) {subject.filter_for(region)}
	let(:kaikoura) {Geospatial::Location.new(173.6814, -42.4008)}
end

RSpec.describe Geospatial::Polygon.new([Vector[0.0, 0.0], Vector[1.0, 0.0], Vector[0.0, 1.0]]) do
	it "should intersect point on edge" do
		is_expected.to be_include_point(Vector[0.0, 0.0])
	end
	
	it "should not intersect point outside" do
		is_expected.to_not be_include_point(Vector[1.0, 0.5])
	end
	
	it "should intersect point inside" do
		is_expected.to be_include_point(Vector[0.2, 0.2])
	end
end

RSpec.describe Geospatial::Map.for_earth(22) do
	include_context "kaikoura region"
	
	it "should contain some prefixes" do
		expect(filter.ranges).to_not be_empty
	end
	
	it "should contain kaikoura" do
		point = subject.point_for_object(kaikoura)
		expect(filter).to include(point)
	end
end

RSpec.describe Geospatial::Polygon do
	include_context "kaikoura region"
	
	def visualise(map)
		margin = 10
		scale = 16.0
		size = map.bounds.size.to_a
		half_size = size.map{|i| i.to_f / 2}
		origin = [size[0] / 2, size[1] / 2]
		
		pdf = Prawn::Document.new(
			page_size: [(size[0] + 40) * scale, (size[1] + 40) * scale],
			margin: 20,
		)
		
		pdf.line_width 0.001
		pdf.scale(scale)
		
		world_path = File.expand_path("world.png", __dir__)
		pdf.image world_path, :at => [0, 180], width: 360, height: 180
		
		pdf.stroke_axis(step_length: 45)
		
		pdf.transparent(0.3, 0.9) do
			pdf.stroke_color "000000"
			pdf.fill_color "00abcc"
			
			yield pdf, Vector[*origin]
		
			pdf.fill_color "00ff00"
			
			map.points.each do |point|
				center =  [origin[0] + point[0], origin[1] + point[1]]
				pdf.circle center, 0.1
			end
			
			pdf.fill
		end
		
		pdf.render_file "polygon.pdf"
	end
	
	it "can generate visualisation" do
		map = Geospatial::Map.for_earth
		
		map << kaikoura
		
		visualise(map) do |pdf, origin|
			region.edges do |pa, pb|
				pdf.line (origin + pa).to_a, (origin + pb).to_a
			end
			
			#count = 0
			map.traverse(region, depth: map.order - 15) do |child, prefix, order|
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
