Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "tasks#index"
  post 'auth', to: 'application#auth'

  resources :tasks, only: %i[index create update destroy] do
    post :finish, on: :member
    post :shuffle, on: :collection
  end
end
