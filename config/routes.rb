Rails.application.routes.draw do
  root "pages#home"

  get "acting_as", to: "acting_as#update", as: :acting_as
  resources :listings, only: [:index, :show, :edit, :update, :destroy] do
    member do
      patch :publish
      patch :withdraw
      patch :mark_rented
    end
    resources :applications, only: :create
  end
  resources :properties do
    resources :listings, only: [:new, :create], controller: "listings"
    resources :reviews, only: [:create, :edit, :update, :destroy]
  end
  resources :neighborhoods
  resources :amenities, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :applications, only: [:index, :show, :update] do
    resources :visits, only: [:create, :update]
    member { patch :withdraw }
  end

  get "up" => "rails/health#show", as: :rails_health_check
end