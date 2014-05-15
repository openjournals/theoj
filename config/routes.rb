Theoj::Application.routes.draw do
  resources :papers, defaults: { format: 'json' } do
    resources :annotations, defaults: { format: 'json' }
  end  
  
  get '/sessions/new', to: 'sessions#new', as: 'new_session'
  get '/auth/:provider/callback', to: 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout
    
  root :to => 'home#index'
end
