require 'sidekiq/web'

Rails.application.routes.draw do
  resources :orders, only: [:index, :show]
  resources :cart_items
  resource :cart, only: [:show]
  resources :reviews
  resource :profile, only: [:show, :edit, :update], controller: "users"

  post "payments/create_order", to: "payments#create_order"
  post "payments/capture_order", to: "payments#capture_order"
  get  "payments/thank_you", to: "payments#thank_you"

  resources :purchases
  resources :products do
  collection do
    get :search_suggestions
  end
end

  resources :subscriptions, only: [:new, :create, :show] do
    collection do
      get :success      
      get :cancel       
      post :webhook     
    end

    member do
      post :cancel_paypal  # /subscriptions/:id/cancel_paypal
    end
  end

  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  root "products#index"
  mount Sidekiq::Web, at: "/jobs"
end
