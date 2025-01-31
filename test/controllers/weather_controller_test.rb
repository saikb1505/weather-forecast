require "test_helper"
require "mocha/minitest"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  def setup
    @address = "Hyderabad, India"
    @zip_code = "500001"
    @latitude = 17.4931
    @longitude = 78.4054

    @weather_data = {
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

    GeocoderService.stubs(:fetch_zip_code).with(@address).returns([@zip_code, @latitude, @longitude])
  end

  test "POST /forecast retrieves weather data and redirects" do
    WeatherService.stubs(:fetch_weather).with(@address).returns({ data: @weather_data, from_cache: false })

    post forecast_path, params: { address: @address }

    assert_redirected_to forecast_path(address: @address)
    follow_redirect!

    assert_response :success
    assert_select "p", text: /Temperature:.*305.86 K/
  end

  test "GET /forecast displays weather data if available" do
    WeatherService.stubs(:fetch_weather).with(@address).returns({ data: @weather_data, from_cache: false })

    get forecast_path, params: { address: @address }

    assert_response :success
    assert_select "p", text: /Temperature:.*305.86 K/
    assert_select "p", text: /Condition:.*broken clouds/
  end

  test "POST /forecast handles missing address" do
    post forecast_path, params: { address: "" }

    assert_redirected_to root_path
    follow_redirect!

    assert_response :success
    assert flash[:alert], "Expected a flash alert for missing address"
  end

  test "POST /forecast handles API failure" do
    WeatherService.stubs(:fetch_weather).with(@address).returns(nil)

    post forecast_path, params: { address: @address }

    assert_redirected_to root_path
    follow_redirect!

    assert_response :success
    assert_equal "Unable to retrieve weather data. Please try again.", flash[:alert]
  end

  test "GET /forecast includes cache indicator when using cached data" do
    WeatherService.stubs(:fetch_weather).with(@address).returns({ data: @weather_data, from_cache: true })

    get forecast_path, params: { address: @address }

    assert_response :success
    assert_select "p", text: /\(This data was retrieved from cache\)/
  end
end
