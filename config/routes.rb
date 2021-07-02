Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  
  resources :physicians, only: [:index, :new, :create]
  resources :counsellors, only: [:index, :new, :create]
end
