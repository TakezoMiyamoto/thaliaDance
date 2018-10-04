Rails.application.routes.draw do
  # devise_for :users
  root to: "top#index"
  devise_for :users, controllers: {
      :omniauth_callbacks => "users/omniauth_callbacks",
  }

  # resources :works
  get 'works', to: 'works#index'

  get 'works/my_works', to: 'works#my_works'
end
