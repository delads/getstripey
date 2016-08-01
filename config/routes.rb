Rails.application.routes.draw do

  root 'pages#home'
  get '/home', to: 'pages#home'

  resources :products do
    member do
      post 'like'
    end
  end
  
  resources :merchants, except: [:new] 
  
  get '/register', to: 'merchants#new'
  
  get '/login', to: "logins#new"
  post '/login', to: "logins#create"
  get '/logout', to: "logins#destroy"
  
end
