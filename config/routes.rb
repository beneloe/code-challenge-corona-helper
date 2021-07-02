Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  
  resources :helpers, only: [:index, :new, :create]
end
