Rails.application.routes.draw do
  get 'helpers/create'
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :helpers, only: [:index, :create]
end
