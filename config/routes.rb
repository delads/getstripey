Rails.application.routes.draw do

  root 'pages#home'
  get '/home', to: 'pages#home'

  resources :products do
    member do
      post 'like'
    end
  end
  
  
  
  resources :merchants, except: [:new] 
  resources :connects
  resources :jsons
  resources :checkouts,  only: [:new, :create, :show]
  
  get '/authorize', to: 'connects#authorize'
  get '/disconnect', to: 'connects#disconnect'
  post '/webhook', to: 'connects#webhook'
  
  get '/register', to: 'merchants#new'
  
  get '/login', to: "logins#new"
  post '/login', to: "logins#create"
  get '/logout', to: "logins#destroy"
  
  post '/pay', to: "products#pay"
  post '/payandroid', to: "products#payandroid"
  post '/pay_braintree', to: "products#pay_braintree"
  
  get '/getbraintreetoken', to: "products#getbraintreetoken"

  
  
  
end
