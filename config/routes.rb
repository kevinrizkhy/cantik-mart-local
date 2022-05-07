Rails.application.routes.draw do

  get 'activities/index'
	Clearance.configure do |config|
  		config.routes = false
	end
  namespace :admin do
      resources :users
      resources :stores

      root to: "users#index"
    end
  root :to => "homes#index"
  resources :registers, only: %i[new create]

  # Clearance
  resource :session, controller: 'sessions', only:  %i[create]
  get '/sign_in', to: 'sessions#new', as: 'sign_in'

  delete '/sign_out', to: 'sessions#destroy'

  get '/api/:api_type', to: 'apis#index'
  post '/api/trx/post', to: 'transactions#create_trx'
  get '/get/:type', to: 'gets#index'

  resources :items
  resources :grocer_items
  resources :item_cats
  resources :departments
  resources :notifications, only: %i[index]

  resources :stocks
  resources :users
  resources :members
  resources :stores

  resources :absents, only: %i[index show]

  resources :transactions, only: %i[index new create]
  resources :transaction_items, only: %i[index show]

  resources :controllers
  resources :methods

  resources :server_informations, only: %i[index]

  get "/sync/now", to:"homes#sync", as: 'sync_now'

  post "/sync/update_store", to:"homes#update_store", as: 'update_store'

  post "/sync/daily", to:"homes#sync_daily", as: 'sync_daily'

  get "/403", to: "errors#no_access_right", as: 'no_access_right'
  get "/404", to: "errors#not_found", as: 'not_found'
  get "/422", to: "errors#unacceptable", as: 'unacceptable'
  get "/500", to: "errors#internal_error", as: 'internal_error'

end
