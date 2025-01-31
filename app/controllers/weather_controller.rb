class WeatherController < ApplicationController
  def forecast
    @address = params[:address]
    return unless @address.present?

    weather_result = WeatherService.fetch_weather(@address)

    if weather_result.nil?
      flash[:alert] = 'Unable to retrieve weather data. Please try again.'
      redirect_to root_path and return
    end

    @weather = weather_result[:data]
    @from_cache = weather_result[:from_cache]

    redirect_to forecast_path(address: @address) if request.post?
  end
end
