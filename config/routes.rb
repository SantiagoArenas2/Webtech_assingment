Rails.application.routes.draw do
  root "pages#home"

  resources :listings, only: [:index, :show]
  resources :properties, only: [:index, :show]
  resources :neighborhoods, only: [:index, :show]
  resources :applications, only: [:index, :show]

  get "up" => "rails/health#show", as: :rails_health_check
end