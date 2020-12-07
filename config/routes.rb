require 'sidekiq/web'
# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  post '/stripe/webhook', to: 'stripe#webhook'

  post '/stripe/create_checkout_session'
  post '/stripe/create_customer_portal_session', to: "stripe#create_customer_portal_session"
  post '/stripe/create_subscription', to: 'stripe#create_subscription'
  post '/stripe/cancel_subscription', to: 'stripe#cancel_subscription'
  post '/stripe/finalize_subscription', to: 'stripe#finalize_subscription'
  post '/stripe/retry_invoice', to: 'stripe#retry_invoice'
  get '/stripe/subscription_status', to: 'stripe#subscription_status'

  get '/stripe', to: 'home#stripe'

  get '/canceled', to: 'home#canceled'
  get '/success', to: 'home#success'

  get '/privacy', to: 'home#privacy'
  get '/terms', to: 'home#terms'
  get '/refund', to: 'home#refund'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
    mount Split::Dashboard, at: 'split'

    namespace :admin do
      resources :users
      resources :announcements
      resources :check_ins
      resources :accounts
      resources :members
      resources :notifications
      resources :subscribers
      resources :answers
      resources :services

      root to: "users#index"
    end
  end

  resources :notifications, only: [:index]
  resources :announcements, only: [:index]
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks", registrations: 'users/registrations' }
  
  root to: 'home#index'

  scope "/:account_id", as: "account" do
    root to: 'accounts#home'
    get '/admin', to: 'accounts#admin'
    get '/billing', to: 'accounts#billing'
    get '/edit', to: 'accounts#edit'
    patch '/update', to: 'accounts#update'

    resources :members
    
    resources :check_ins do
      resources :answers

      member do 
        post '/send_test', to: "check_ins#send_test"
        post '/send_now', to: "check_ins#send_now"

        resources :subscribers do
          collection do 
            get '/import', to: "subscribers#import"
            post '/import', to: "subscribers#import_subscribers"
          end
        end

      end
    end
  end
  
end
