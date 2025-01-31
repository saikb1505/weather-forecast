class WeatherService
  require 'httparty'

  API_KEY = ENV.fetch('WEATHER_API_KEY', nil)
  BASE_URL = "https://api.openweathermap.org/data/3.0/onecall"

  def self.fetch_weather(address)
    zip_code, lat, lon = GeocoderService.fetch_zip_code(address)
    return nil if zip_code.nil?

    cache_key = "weather_#{zip_code}"
    cached_data = Rails.cache.read(cache_key)
    return { data: cached_data, from_cache: true } if cached_data

    weather_data = request_weather_data(lat, lon)
    return nil unless weather_data

    Rails.cache.write(cache_key, weather_data, expires_in: cache_expiration_time)
    { data: weather_data, from_cache: false }
  end

  private

  def self.request_weather_data(lat, lon)
    # https://api.openweathermap.org/data/3.0/onecall?lat={lat}&lon={lon}&appid={API key}
    response = HTTParty.get("#{BASE_URL}?lat=#{lat}&lon=#{lon}&appid=#{API_KEY}")

    if response.code == 404
      Rails.logger.warn "Weather API Error: #{response['message']}"
      return nil
    elsif !response.success?
      Rails.logger.error "Weather API Failure: #{response.body}"
      return nil
    end

    data = JSON.parse(response.body)

    {
      current_temp: data.dig("current", "temp"),
      feels_like: data.dig("current", "feels_like"),
      high: data.dig("daily", 0, "temp", "max"),
      low: data.dig("daily", 0, "temp", "min"),
      humidity: data.dig("current", "humidity"),
      wind_speed: data.dig("current", "wind_speed"),
      visibility: data.dig("current", "visibility"),
      description: data.dig("current", "weather", 0, "description"),
      extended_forecast: data.dig("daily", 0, "summary"),
      from_cache: false
    }

  rescue StandardError => e
    Rails.logger.error "Weather API Request Failed: #{e.message}"
    nil
  end

  def self.cache_expiration_time
    ENV.fetch('CACHE_EXPIRATION', 30).to_i.minutes
  end

end
