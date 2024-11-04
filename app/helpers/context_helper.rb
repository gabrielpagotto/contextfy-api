module ContextHelper
  class HaversineCalculator
    EARTH_RADIUS_METERS = 6_371_000

    def self.haversine_distance(lat1, lon1, lat2, lon2)
      validate_coordinates(lat1, lon1)
      validate_coordinates(lat2, lon2)

      lat1_rad, lon1_rad = to_radians(lat1), to_radians(lon1)
      lat2_rad, lon2_rad = to_radians(lat2), to_radians(lon2)

      d_lat = lat2_rad - lat1_rad
      d_lon = lon2_rad - lon1_rad

      a = Math.sin(d_lat / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(d_lon / 2) ** 2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
      EARTH_RADIUS_METERS * c
    end

    private

    def self.to_radians(degrees)
      degrees * Math::PI / 180
    end

    def self.validate_coordinates(lat, lon)
      unless lat.is_a?(Numeric) && lon.is_a?(Numeric)
        raise ArgumentError, "Latitude and Longitude must be numeric values."
      end

      unless lat.between?(-90, 90)
        raise ArgumentError, "Latitude must be between -90 and 90 degrees."
      end

      unless lon.between?(-180, 180)
        raise ArgumentError, "Longitude must be between -180 and 180 degrees."
      end
    end
  end
end
