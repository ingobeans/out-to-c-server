Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "auth/callback" => "auth#callback"
  get "auth/test" => "auth#test"
  get "auth/dev" => "auth#dev"
  root "home#index"
end
