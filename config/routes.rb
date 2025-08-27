require 'sidekiq/web'
Rails.application.routes.draw do
  resources :orders
  resources :cart_items
  resource :cart, only: [:show]
  resources :reviews
  post "payments/create_order", to: "payments#create_order"
  post "payments/capture_order", to: "payments#capture_order"
  get  "payments/thank_you", to: "payments#thank_you"

  resources :purchases
  resources :products do 
    post "buy", on: :member
  end

  resources :subscriptions, only: [:new, :create] do
  collection do
    get :success      # /subscriptions/success
    get :cancel       # /subscriptions/cancel
    post :webhook     # /subscriptions/webhook
  end

  member do
    post :cancel_paypal  # /subscriptions/:id/cancel_paypal
  end
end

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
  mount Sidekiq::Web, at: "/jobs"
end
