require_relative 'boot'

require 'rails/all'
require 'dotenv'

# Load environment variables from .env
Dotenv.load

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WeatherApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Ensure ENV variables are available in Rails
    config.before_configuration do
      Dotenv.load if defined?(Dotenv)
    end
  end
end
