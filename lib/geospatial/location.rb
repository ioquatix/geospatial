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

require_relative 'distance'

module Geospatial
	# This location is specifically relating to a WGS84 coordinate on Earth.
	class Location
		# WGS 84 semi-major axis constant in meters
		WGS84_A = 6378137.0
		# WGS 84 semi-minor axis constant in meters
		WGS84_B = 6356752.3
		
		EARTH_RADIUS = (WGS84_A + WGS84_B) / 2.0
		
		# WGS 84 eccentricity
		WGS84_E = 8.1819190842622e-2

		# Radians to degrees multiplier
		R2D = (180.0 / Math::PI)
		D2R = (Math::PI / 180.0)

		MIN_LONGITUDE = -180 * D2R
		MAX_LONGITUDE = 180 * D2R
		VALID_LONGITUDE = MIN_LONGITUDE...MAX_LONGITUDE

		MIN_LATITUDE = -90.0 * D2R
		MAX_LATITUDE = 90 * D2R
		VALID_LATITUDE = MIN_LATITUDE...MAX_LATITUDE
		
		class << self
			def from_ecef(x, y, z)
				# Constants (WGS ellipsoid)
				a = WGS84_A
				e = WGS84_E
		
				b = Math::sqrt((a*a) * (1.0-(e*e)))
				ep = Math::sqrt(((a*a)-(b*b))/(b*b))
				
				p = Math::sqrt((x*x)+(y*y))
				th = Math::atan2(a*z, b*p)
				
				lon = Math::atan2(y, x)
				lat = Math::atan2((z+ep*ep*b*(Math::sin(th) ** 3)), (p-e*e*a*(Math::cos(th)**3)))
				
				n = a / Math::sqrt(1.0-e*e*(Math::sin(lat) ** 2))
				# alt = p / Math::cos(lat)-n
				
				return self.new(lat*R2D, lon*R2D)
			end
			
			alias [] new
		end
		
		def initialize(longitude, latitude)
			@longitude = longitude
			@latitude = latitude
		end
		
		def valid?
			VALID_LONGITUDE.include?(longitude) and VALID_LATITUDE.include?(latitude)
		end
		
		def to_a
			[@longitude, @latitude]
		end
		
		def to_s
			"#{self.class}#{self.to_a.inspect}"
		end
		
		alias inspect to_s
		
		attr :longitude # -180 -> 180 (equivalent to x)
		attr :latitude # -90 -> 90 (equivalent to y)
		
		# http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates
		def bounding_box(distance, radius = EARTH_RADIUS)
			raise ArgumentError.new("Invalid distance or radius") if distance < 0 or radius < 0

			# angular distance in radians on a great circle
			angular_distance = distance / radius

			min_latitude = (self.latitude * D2R) - angular_distance
			max_latitude = (self.latitude * D2R) + angular_distance

			if min_latitude > MIN_LATITUDE and max_latitude < MAX_LATITUDE
				longitude_delta = Math::asin(Math::sin(angular_distance) / Math::cos(self.latitude * D2R))
				
				min_longitude = (self.longitude * D2R) - longitude_delta
				min_longitude += 2.0 * Math::PI if (min_longitude < MIN_LONGITUDE)
				
				max_longitude = (self.longitude * D2R) + longitude_delta;
				max_longitude -= 2.0 * Math::PI if (max_longitude > MAX_LONGITUDE)
			else
				# a pole is within the distance
				min_latitude = [min_latitude, MIN_LATITUDE].max
				max_latitude = [max_latitude, MAX_LATITUDE].min
				
				min_longitude = MIN_LONGITUDE
				max_longitude = MAX_LONGITUDE
			end
			
			return {
				:latitude => Range.new(min_latitude * R2D, max_latitude * R2D),
				:longitude => Range.new(min_longitude * R2D, max_longitude * R2D),
			}
		end
		
		# Converts latitude, longitude to ECEF coordinate system
		def to_ecef
			clon = Math::cos(lon * D2R)
			slon = Math::sin(lon * D2R)
			clat = Math::cos(lat * D2R)
			slat = Math::sin(lat * D2R)

			n = WGS84_A / Math::sqrt(1.0 - WGS84_E * WGS84_E * slat * slat)
		
			x = n * clat * clon
			y = n * clat * slon
			z = n * (1.0 - WGS84_E * WGS84_E) * slat
	
			return x, y, z
		end
		
		# calculate distance in metres between us and something else
		# ref: http://codingandweb.blogspot.co.nz/2012/04/calculating-distance-between-two-points.html
		def distance_from(other)
			rlong1 = self.longitude * D2R 
			rlat1 = self.latitude * D2R 
			rlong2 = other.longitude * D2R 
			rlat2 = other.latitude * D2R 
			
			dlon = rlong1 - rlong2
			dlat = rlat1 - rlat2
			
			a = Math::sin(dlat/2) ** 2 + Math::cos(rlat1) * Math::cos(rlat2) * Math::sin(dlon/2) ** 2
			c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
			d = EARTH_RADIUS * c
			
			return d
		end
		
		def - other
			Distance.new(self.distance_from(other))
		end
	end
end
