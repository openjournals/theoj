Theoj::Application.routes.draw do

  get '/papers/:paper_id/issues', to: "annotations#issues"

  resources :papers, only:[:index, :show, :create], defaults: { format: 'json' } do

    collection do
      get :as_reviewer, defaults: { format: 'json' }
      get :as_editor, defaults: { format: 'json' }
      get :as_author, defaults: { format: 'json' }
      get :as_collaborator, defaults: { format: 'json' }
    end

    member do
      get  :state, defaults: { format: 'html' }
      put  :transition, format: 'json'

      get  :arXiv_details, :id => /[0-9]{4}.*[0-9]{4}/
    end

    resources :assignments, only:[:index, :create, :destroy]

    resources :annotations, only:[:index, :create], defaults: { format: 'json' } do
      member do
        # Change status
        put :unresolve
        put :dispute
        put :resolve
      end
    end

  end

  get '/current_user', to:'users#get_current_user', defaults: {format: 'json'}

  resources :users, defaults: { format: 'json' }, only: [] do
    resources :papers, defaults: { format: 'json' } do
      collection do
        get :as_reviewer, defaults: { format: 'json' }
        get :as_editor, defaults: { format: 'json' }
        get :as_author, defaults: { format: 'json' }
        get :as_collaborator, defaults: { format: 'json' }
      end
    end

    collection do
      get :name_lookup, defaults: { format: 'json' }
    end
  end

  get '/user/name_lookup', to: 'users#name_lookup'

  get '/sessions/new', to: 'sessions#new', as: 'new_session'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get "/signout" => "sessions#destroy", :as => :signout

  root :to => 'home#index'
end
