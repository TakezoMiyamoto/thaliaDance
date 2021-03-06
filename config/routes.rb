Rails.application.routes.draw do
  # devise_for :users
  root to: "top#index"
  devise_for :users, controllers: {
      :omniauth_callbacks => "users/omniauth_callbacks",
  }

  resources :users, except: [:index]

  resources :works

  get 'myworks/index', to: 'myworks#index'
end
