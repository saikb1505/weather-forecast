Rails.application.routes.draw do
  root 'weather#forecast'  # Ensure a root path exists

  get 'forecast', to: 'weather#forecast'   # Keep GET for direct URL access
  post 'forecast', to: 'weather#forecast'  # Allow form submission via POST

  # Health check route (for uptime monitoring)
  get "up" => "rails/health#show", as: :rails_health_check
end