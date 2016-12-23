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

require 'matrix'

module Geospatial
	# A circle is a geometric primative where the center is a location and the radius is in meters.
	class Circle
		alias [] new
		
		# Center must be a vector, radius must be a numeric value.
		def initialize(center, radius)
			@center = center
			@radius = radius
		end
		
		attr :center
		attr :radius
		
		def to_s
			"#{self.class}[#{@center}, #{@radius}]"
		end
		
		def distance_from(point)
			Location.new(point[0], point[1]).distance_from(@center)
		end
		
		def include_point?(point, radius = @radius)
			distance_from(point) <= radius
		end
		
		def include_box?(other)
			# We must contain the for corners of the other box:
			other.corners do |corner|
				return false unless include_point?(corner)
			end
			
			return true
		end
		
		def include_circle?(other)
			# We must be big enough to contain the other point:
			@radius >= other.radius && include_point?(other.center.to_a, @radius - other.radius)
		end
		
		def include?(other)
			case other
			when Box
				include_box?(other)
			when Circle
				include_circle?(other)
			end
		end
		
		def intersect?(other)
			case other
			when Box
				intersect_with_box?(other)
			when Circle
				intersect_with_circle?(other)
			end
		end
		
		def midpoints
			@bounds ||= @center.bounding_box(@radius)
			
			yield([@bounds[:longitude].begin, @center.latitude])
			yield([@bounds[:longitude].end, @center.latitude])
			yield([@center.longitude, @bounds[:latitude].begin])
			yield([@center.longitude, @bounds[:latitude].end])
		end
		
		def intersect_with_box?(other)
			# If we contain any of the four corners:
			other.corners do |corner|
				return true if include_point?(corner)
			end
			
			midpoints do |midpoint|
				return true if other.include_point?(midpoint)
			end
			
			return false
		end
		
		def intersect_with_circle?(other)
			include_point?(other.center.to_a, @radius + other.radius)
		end
	end
end
