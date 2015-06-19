Theoj::Application.routes.draw do

  scope path:'api', as:'api', defaults: { format: 'json' } do

    get '/papers/:paper_id/issues', to: "annotations#issues"

    resources :papers, only:[:index, :show, :create] do

      collection do
        get :as_reviewer
        get :as_editor
        get :as_author
        get :as_collaborator
      end

      member do
        put  :check_for_update, id: Paper::ArxivIdRegex
        get  :arxiv_details,    id: Paper::ArxivIdWithVersionRegex
        get  :versions,         id: Paper::ArxivIdRegex

        get  :state
        put  :transition

        post  :complete
        match :public,   via:[:post, :delete]
      end

      resources :assignments, only:[:index, :create, :destroy]

      resources :annotations, only:[:index, :create] do
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

    get 'review/:sha', as:'paper_review'

  end

end
