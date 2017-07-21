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

require_relative 'visualization'

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
	it "should have 3 points" do
		expect(subject.points.count).to be == 3
	end
	
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
	
	it "generates correct number of ranges" do
		map = Geospatial::Map.for_earth(30)
		filter = map.filter_for(region, depth: 12)
		expect(filter.ranges.count).to be 166
	end
	
	it "can generate visualisation" do
		map = Geospatial::Map.for_earth(30)
		
		map << kaikoura
		
		Geospatial::Visualization.for_map(map) do |pdf, origin|
			region.edges do |pa, pb|
				pdf.line (origin + pa).to_a, (origin + pb).to_a
			end
			
			count = 0
			map.traverse(region, depth: 12) do |child, prefix, order|
				count += 1
				size = child.size
				top_left = (origin + child.min) + Vector[0, size[1]]
				pdf.rectangle(top_left.to_a, *size.to_a)
				# puts "#{top_left.to_a} #{size.to_a}"
			end
			
			# puts "count=#{count}"
			
			pdf.fill_and_stroke
		end.render_file "polygon.pdf"
	end
end

RSpec.shared_context "visualize polygon" do
	it "can generate visualisation" do
		map = Geospatial::Map.for_earth(30)
		
		coordinates = region_string.split(/\s+/).collect{|coordinate| Vector.elements(coordinate.split(',').collect(&:to_f).first(2))}
		region = Geospatial::Polygon.new(coordinates)
		
		Geospatial::Visualization.for_map(map) do |pdf, origin|
			region.edges do |pa, pb|
				pdf.line (origin + pa).to_a, (origin + pb).to_a
			end
			
			count = 0
			map.traverse(region, depth: 12) do |child, prefix, order|
				count += 1
				size = child.size
				top_left = (origin + child.min) + Vector[0, size[1]]
				pdf.rectangle(top_left.to_a, *size.to_a)
				# puts "#{top_left.to_a} #{size.to_a}"
			end
			
			# puts "count=#{count}"
			
			pdf.fill_and_stroke
		end.render_file "#{self.class.description}.pdf"
	end
end

RSpec.describe "Christchurch Polygon" do
	let(:region_string) {"172.5704862712994,-43.48596596137077,0 172.5201239708415,-43.53774028333099,0 172.5497172175809,-43.58329117215316,0 172.604929908906,-43.58160925926914,0 172.6545025267675,-43.56367542997712,0 172.6985236068587,-43.55310361706354,0 172.7121776930187,-43.52196479307798,0 172.696171928184,-43.48585061855334,0 172.6332017124032,-43.45926891264853,0 172.5704862712994,-43.48596596137077,0"}
	
	include_context "visualize polygon"
end

RSpec.describe "Whanganui Polygon" do
	let(:region_string) {"175.0556233581592,-39.89861688271326,0 175.0212702693783,-39.91563023046992,0 174.9982107080192,-39.94106068540562,0 175.0189791159102,-39.95883189352543,0 175.0380433179273,-39.9568297441058,0 175.0580033463029,-39.94526078572716,0 175.0686808831414,-39.92828589884596,0 175.0760889571864,-39.90493548576401,0 175.0556233581592,-39.89861688271326,0"}
	
	include_context "visualize polygon"
end
