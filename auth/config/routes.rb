Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :users, only: %i[index update destroy]
  post :sign_up, to: 'users#create'
  post :sign_in, to: 'user_sessions#create'
  get :auth, to: 'auth#index'
end
