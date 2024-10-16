require "test_helper"

class ContextHelperTest < ActiveSupport::TestCase
  include ContextHelper

  test "calculates distance between a point and another point" do
    lat1, lon1 = -27.536755, -48.528756
    lat2, lon2 = -27.536751, -48.528710
    distance = HaversineCalculator.haversine_distance(lat1, lon1, lat2, lon2)
    assert_in_delta 5, distance, 1
  end

  test "returns zero distance for the same point" do
    lat, lon = 51.5074, -0.1278
    distance = HaversineCalculator.haversine_distance(lat, lon, lat, lon)
    assert_equal 0, distance
  end

  test "raises error when latitude is out of range" do
    assert_raises(ArgumentError, "Latitude must be between -90 and 90 degrees") do
      HaversineCalculator.haversine_distance(100, -46.6333, -23.5505, -46.6333)
    end
  end

  test "raises error when longitude is out of range" do
    assert_raises(ArgumentError, "Longitude must be between -180 and 180 degrees") do
      HaversineCalculator.haversine_distance(-23.5505, -200, -23.5505, -46.6333)
    end
  end

  test "raises error when latitude is not numeric" do
    assert_raises(ArgumentError, "Latitude and Longitude must be numeric values") do
      HaversineCalculator.haversine_distance("invalid", -46.6333, -23.5505, -46.6333)
    end
  end
end
