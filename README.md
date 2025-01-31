# Weather Forecast App

Welcome to the **Weather Forecast App**! This is a simple Ruby on Rails application that allows users to enter an address and get real-time weather information, including temperature, high/low forecast, and weather conditions. The app also caches weather data for 30 minutes to improve performance.

## Features

- Enter an address and get the current weather.
- Displays temperature, high/low forecast, and conditions.
- Uses caching to avoid unnecessary API calls (cache expires after 30 minutes).
- Built with Ruby on Rails and uses OpenWeatherMap API for weather data.

## Getting Started

### Prerequisites

Make sure you have the following installed on your machine:

- **Ruby** (version 3.0 or later recommended)
- **Rails** (version 6.1 or later)
- **Bundler**
- **OpenWeatherMap API Key**

### Installation

1. Clone this repository:

   ```sh
   git clone https://github.com/saikb1505/weather-forecast.git
   cd weather-forecast
   ```

2. Install dependencies:

   ```sh
   bundle install
   ```

3. Set up the environment variables:

   - Create a `.env` file in the root of the project.
   - Add your OpenWeatherMap API key:

     ```sh
     WEATHER_API_KEY=your_actual_api_key
     ```

4. Start the Rails server:

   ```sh
   rails server
   ```

5. Open your browser and visit:

   ```sh
   http://localhost:3000
   ```

## API Integration

This app uses **OpenWeatherMap API** to fetch weather details. If you experience issues with fetching weather data, ensure:

- Your API key is correct.
- The location entered is valid.
- The OpenWeatherMap API is up and running.

## File Structure Overview

- `app/controllers/weather_controller.rb` - Handles user input and retrieves weather data.
- `app/services/weather_service.rb` - Fetches weather data and caches results.
- `app/services/geocoding_service.rb` - Converts an address into a zip code.
- `app/views/weather/show.html.erb` - Displays weather details to the user.
- `config/routes.rb` - Defines application routes.
