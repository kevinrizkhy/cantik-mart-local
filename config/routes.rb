Rails.application.routes.draw do

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

  get '/retur/:id/confirmation', to: 'returs#confirmation', as: 'retur_confirmation'
  post '/retur/:id/confirmation', to: 'returs#accept', as: 'retur_accept'

  get '/transfer/:id/confirmation', to: 'transfers#confirmation', as: 'transfer_confirmation'
  post '/transfer/:id/confirmation', to: 'transfers#accept', as: 'transfer_accept'

  get 'transfer/:id/sent', to:'transfers#picked', as: 'transfer_picked'
  post 'transfer/:id/sent', to: 'transfers#sent', as: 'transfer_sent'

  get 'transfer/:id/receive', to: 'transfers#receive', as: 'transfer_receive'
  post 'transfer/:id/received', to: 'transfers#received', as: 'transfer_received'

  get 'order/:id/receive', to: 'orders#confirmation', as: 'order_confirmation'
  post 'order/:id/receive', to: 'orders#receive', as: 'order_receive'
  get 'order/:id/edit/receive', to: 'orders#edit_confirmation', as: 'edit_order_confirmation'
  put 'order/:id/edit/receive', to: 'orders#edit_receive', as: 'edit_order_receive'
  get 'order/:id/pay', to: 'orders#pay', as: 'order_pay'
  post 'order/:id/pay', to: 'orders#paid', as: 'order_paid'

  post '/retur/:id/picked', to: 'returs#picked', as: 'retur_picked'
  get '/retur/:id/feedback', to: 'retur_items#feedback', as: 'retur_feedback'
  post '/retur/:id/confirm_feedback', to: 'retur_items#feedback_confirmation', as: 'retur_feedback_confirmation'

  delete '/sign_out', to: 'sessions#destroy'

  get '/api/:api_type', to: 'apis#index'
  post '/api/trx/post', to: 'transactions#create_trx'

  resources :items, only: %i[index new create edit update]
  resources :item_cats, only: %i[index new create edit update]

  resources :stocks, only: %i[index edit update]
  resources :users
  resources :stores, only: %i[index new create edit update]

  resources :suppliers, only: %i[index new create edit update]
  resources :supplier_items, only: %i[index new create edit update]
  resources :item_suppliers, only: %i[index]

  resources :members, only: %i[index new create edit update]

  resources :returs
  resources :retur_items, only: %i[index new create edit update]

  resources :complains, only: %i[index new create]
  resources :complain_items, only: %i[index]

  resources :absents, only: %i[index]

  resources :transfers
  resources :transfer_items, only: %i[index new create edit update]
  
  resources :retur_warehouses, only: %i[index new create edit update]
  resources :retur_warehouse_items, only: %i[index new create edit update]

  resources :warning_items, only: %i[index new create edit update]

  resources :orders
  resources :order_items, only: %i[index new create edit update]

  resources :transactions, only: %i[index new create]
  resources :transaction_items, only: %i[index]

  resources :cash_flows, only: %i[index new create]
  resources :debts, only: %i[index new create]
  resources :receivables, only: %i[index new create]
  resources :taxs, only: %i[index new create]
  resources :fix_costs, only: %i[index new create]
  resources :operationals, only: %i[index new create]
  resources :stock_values, only: %i[index new create]
  # resources :assets, only: %i[index new create]

  resources :controllers
  resources :methods
  # resources :user_methods

end
