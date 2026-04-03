Rails.application.routes.draw do
  resources :invoice_items

  devise_for :users
  resources :companies do
    # resources :invoices
    resources :invoices do
      collection do
        post :add_item # Pour /invoices/add_item (New)
      end

      member do
        post :add_item # Pour /invoices/:id/add_item (Edit)
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "companies#index"
end
