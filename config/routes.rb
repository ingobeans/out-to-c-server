Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "auth/callback" => "auth#callback"
  root "home#index"
end
