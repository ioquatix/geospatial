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

require_relative '../map'

module Geospatial
	class Map
		# Uses dependency injection to generate a class to `load` and `dump` a serialized column.
		class Index
			class << self
				attr_accessor :map
				
				def load(hash)
					if hash
						map.point_for_hash(hash)
					end
				end
				
				def dump(point)
					if point.is_a?(Point)
						point.hash
					elsif point.respond_to?(:to_a)
						map.hash_for_coordinates(point.to_a)
					elsif !point.nil?
						raise ArgumentError.new("Could not convert #{point} on #{map}!")
					end
				end
			end
		end
		
		# serialize :point, Map.for_earth.index
		def index
			klass = Class.new(Index)
			
			klass.map = self
			
			return klass
		end
	end
end
