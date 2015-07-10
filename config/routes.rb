
Theoj::Application.routes.draw do

  scope path:'api', as:'api', format: 'json'do

    resources :papers, only:[:index, :show, :create, :destroy], param: :identifier,identifier: /[^\/]+/ do

      collection do
        get :recent
        get :as_author
        get :as_collaborator
        get :as_reviewer
        get :as_editor
        get :search
      end

      member do
        get   :preview
        post  action:'create'
        put   :check_for_update
        get   :versions

        get   :state
        put   :transition

        post  :complete
        match :public,   via:[:post, :delete]
      end

      resources :assignments, only:[:index, :create, :destroy]

      resources :annotations, only:[:index, :create] do

        collection do
          get :all
        end

        member do
          # Change status
          put :unresolve
          put :dispute
          put :resolve
        end

      end

    end

    resource :user, only: [:show, :update] do
      collection do
        get :lookup
      end
    end

  end

  get '/sessions/new',            to: 'sessions#new',     as: 'new_session'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure',            to: 'sessions#failure'
  get "/signout",                 to: "sessions#destroy"

  # Make all other routes get the SPA page
  if Rails.env.development?
    get '/*path', to: 'home#index', constraints: { path: /(?!rails).*/ }
  else
    get '/*path', to: 'home#index'
  end
  root            to: 'home#index'

  # Helpers for Polymer Routes
  scope controller:'none', action:'none' do

    get 'review/:identifier', as:'paper_review'

  end

end
