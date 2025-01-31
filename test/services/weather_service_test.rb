require "test_helper"
require "mocha/minitest" # Ensure Mocha is loaded

class WeatherServiceTest < ActiveSupport::TestCase
  def setup
    @address = "Hyderabad, India"
    @zip_code = "500001"
    @latitude = 17.4931
    @longitude = 78.4054
    Rails.cache.clear
  end

  def mock_api_response
    {
      "current" => {
        "temp" => 305.86,
        "feels_like" => 304.12,
        "humidity" => 24,
        "wind_speed" => 1.54,
        "visibility" => 6000,
        "weather" => [{ "description" => "broken clouds" }]
      },
      "daily" => [
        { "temp" => { "max" => 305.86, "min" => 292.72 }, "summary" => "Expect a day of partly cloudy with clear spells" }
      ]
    }
  end

  def expected_weather_data
    {
      current_temp: 305.86,
      feels_like: 304.12,
      high: 305.86,
      low: 292.72,
      humidity: 24,
      wind_speed: 1.54,
      visibility: 6000,
      description: "broken clouds",
      extended_forecast: "Expect a day of partly cloudy with clear spells",
      from_cache: false
    }
  end

  test "fetch_weather retrieves data from API and caches it" do
    GeocoderService.stubs(:fetch_zip_code).with(@address).returns([@zip_code, @latitude, @longitude])
    WeatherService.stubs(:request_weather_data).with(@latitude, @longitude).returns(expected_weather_data)

    result = WeatherService.fetch_weather(@address)

    assert_not_nil result, "Expected weather data, but got nil"
    assert_equal expected_weather_data, result[:data], "Weather data mismatch"
    assert_equal false, result[:from_cache], "Expected from_cache to be false"

    assert Rails.cache.exist?("weather_#{@zip_code}"), "Expected data to be cached"
  end

  test "fetch_weather returns cached data if available" do
    Rails.cache.write("weather_#{@zip_code}", expected_weather_data, expires_in: 30.minutes)

    GeocoderService.stubs(:fetch_zip_code).with(@address).returns([@zip_code, @latitude, @longitude])

    result = WeatherService.fetch_weather(@address)

    assert_not_nil result, "Expected cached weather data, but got nil"
    assert_equal expected_weather_data, result[:data], "Cached weather data mismatch"
    assert_equal true, result[:from_cache], "Expected from_cache to be true for cached data"
  end

  test "fetch_weather returns nil for invalid address" do
    GeocoderService.stubs(:fetch_zip_code).with(@address).returns([nil, nil, nil])

    result = WeatherService.fetch_weather(@address)

    assert_nil result, "Expected nil for invalid address"
  end

  test "fetch_weather handles API failure gracefully" do
    GeocoderService.stubs(:fetch_zip_code).with(@address).returns([@zip_code, @latitude, @longitude])
    WeatherService.stubs(:request_weather_data).with(@latitude, @longitude).returns(nil)

    result = WeatherService.fetch_weather(@address)

    assert_nil result, "Expected nil when API request fails"
  end

  test "fetch_weather logs API errors" do
    GeocoderService.stubs(:fetch_zip_code).with(@address).returns([@zip_code, @latitude, @longitude])
    
    Rails.logger.expects(:error).with(includes("Weather API Request Failed")) # Correctly stub Rails.logger

    WeatherService.stubs(:request_weather_data).with(@latitude, @longitude).raises(StandardError.new("API Error"))

    assert_nil WeatherService.fetch_weather(@address), "Expected nil when API request fails"
  end
end
