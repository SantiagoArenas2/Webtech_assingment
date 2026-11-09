Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  resources :passwords, only: %i[new create edit update], param: :token
  resources :registrations, only: %i[new create], path: "sign_up"
  resource :profile, only: %i[edit update]
  root "pages#home"

  namespace :api do
    namespace :v1 do
      resources :listings, only: %i[index show]
    end
  end
  resources :listings, only: [:index, :show, :edit, :update, :destroy] do
    member do
      patch :publish
      patch :withdraw
      patch :mark_rented
    end
    resources :applications, only: :create
    resources :reports, only: :create
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
  resources :reports, only: :index do
    member { patch :resolve }
  end

  get "up" => "rails/health#show", as: :rails_health_check
end