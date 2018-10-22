Rails.application.routes.draw do
  # devise_for :users
  root to: "top#index"
  devise_for :users, controllers: {
      :omniauth_callbacks => "users/omniauth_callbacks",
  }

  get '/auth/:provider/callback', to: 'myworks#google'

  resources :users, except: [:index]

  resources :works

  get 'myworks/index', to: 'myworks#index'
  get 'myworks/google', to: 'myworks#google'

end
