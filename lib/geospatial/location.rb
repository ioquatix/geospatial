
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

		MIN_LATITUDE = -90.0 * D2R
		MAX_LATITUDE = 90 * D2R
		VALID_LATITUDE = MIN_LATITUDE...MAX_LATITUDE
		
		MIN_LONGITUDE = -180 * D2R
		MAX_LONGITUDE = 180 * D2R
		VALID_LONGITUDE = MIN_LONGITUDE...MAX_LONGITUDE
		
		def initialize(latitude, longitude, altitude = 0)
			@latitude = latitude
			@longitude = longitude
			@altitude = altitude
		end
		
		def valid?
			VALID_LATITUDE.include? latitude and VALID_LONGITUDE.include? longitude
		end
		
		def to_s
			"#<Location latitude=#{@latitude} longitude=#{@longitude.to_f} altitude=#{@altitude.to_f}>"
		end
		
		alias inspect to_s
		
		attr :latitude
		attr :longitude
		attr :altitude
		
		# http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates
		def bounding_box(distance, radius = EARTH_RADIUS)
			raise ArgumentError.new("Invalid distance or radius") if distance < 0 or radius < 0

			# angular distance in radians on a great circle
			angular_distance = distance / (radius + self.altitude)

			min_latitude = (self.latitude * D2R) - angular_distance
			max_latitude = (self.latitude * D2R) + angular_distance

			if min_latitude > MIN_LAT and max_latitude < MAX_LAT
				longitude_delta = Math::asin(Math::sin(angular_distance) / Math::cos(self.latitude * D2R))
				
				min_longitude = (self.longitude * D2R) - longitude_delta
				min_longitude += 2.0 * Math::PI if (min_longitude < MIN_LON)
				
				max_longitude = (self.longitude * D2R) + longitude_delta;
				max_longitude -= 2.0 * Math::PI if (max_longitude > MAX_LON)
			else
				# a pole is within the distance
				min_latitude = [min_latitude, MIN_LAT].max
				max_latitude = [max_latitude, MAX_LAT].min
				
				min_longitude = MIN_LON
				max_longitude = MAX_LON
			end
			
			return {
				:latitude => Range.new(min_latitude * R2D, max_latitude * R2D),
				:longitude => Range.new(min_longitude * R2D, max_longitude * R2D),
			}
		end
		
		# Converts latitude, longitude to ECEF coordinate system
		def to_ecef(alt)
			clat = Math::cos(lat * D2R)
			slat = Math::sin(lat * D2R)
			clon = Math::cos(lon * D2R)
			slon = Math::sin(lon * D2R)
		
			n = WGS84_A / Math::sqrt(1.0 - WGS84_E * WGS84_E * slat * slat)
		
			x = (n + alt) * clat * clon
			y = (n + alt) * clat * slon
			z = (n * (1.0 - WGS84_E * WGS84_E) + alt) * slat
	
			return x, y, z
		end
	
		def self.from_ecef(x, y, z)
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
			alt = p / Math::cos(lat)-n
	
			return self.new(lat*R2D, lon*R2D, alt)
		end
		
		# calculate distance in metres between us and something else
		# ref: http://codingandweb.blogspot.co.nz/2012/04/calculating-distance-between-two-points.html
		def distance_from(other_position)
			rlat1 = self.latitude * D2R 
			rlong1 = self.longitude * D2R 
			rlat2 = other_position.latitude * D2R 
			rlong2 = other_position.longitude * D2R 
			
			dlon = rlong1 - rlong2
			dlat = rlat1 - rlat2
			
			a = Math::sin(dlat/2) ** 2 + Math::cos(rlat1) * Math::cos(rlat2) * Math::sin(dlon/2) ** 2
			c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
			d = EARTH_RADIUS * c
			
			return d
		end
	end
end
