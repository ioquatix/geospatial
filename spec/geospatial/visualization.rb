
require 'geospatial/map'
require 'prawn'

module Geospatial
	module Visualization
		def self.for_map(map)
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
			
			return pdf
		end
	end
end
