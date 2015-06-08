Theoj::Application.routes.draw do

  scope path:'api' do

    get '/papers/:paper_id/issues', to: "annotations#issues"

    resources :papers, only:[:index, :show, :create], defaults: { format: 'json' } do

      collection do
        get :as_reviewer,     defaults: { format: 'json' }
        get :as_editor,       defaults: { format: 'json' }
        get :as_author,       defaults: { format: 'json' }
        get :as_collaborator, defaults: { format: 'json' }
      end

      member do
        put  :check_for_update, id: Paper::ArxivIdRegex
        get  :arxiv_details,    id: Paper::ArxivIdWithVersionRegex
        get  :versions,         id: Paper::ArxivIdRegex

        get  :state, defaults: { format: 'html' }
        put  :transition, format: 'json'
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

    resource :user, defaults: { format: 'json' }, only: [:show, :update] do
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
end
