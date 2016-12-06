
Theoj::Application.routes.draw do

  namespace :api, format: 'json' do

    namespace :v1 do

      resources :papers, only:[:index, :show, :create, :destroy], param: :identifier, identifier: /[^\/]+/ do

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

  end

  get '/sessions/new',            to: 'sessions#new',     as: 'new_session'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure',            to: 'sessions#failure'
  get "/signout",                 to: "sessions#destroy"

  resources :papers, only: [], param: :identifier, identifier: /[^\/]+/ do
    member do
      # Add custom review badge URL for now
      get 'badge',     action: 'badge'
    end
  end

  scope 'feed', controller:'feed' do
    get 'arxiv(.:format)',      action: 'arxiv',  defaults: { format:'xml' }
  end

  scope 'admin', controller:'admin' do
    get '',           action: 'index'
    get 'overview',   action: 'index'
  end

  ##################################################################
  # Make all other routes get the SPA page

  if Rails.env.development?
    get '/*path', to: 'home#index', constraints: { path: /(?!rails).*/ }
  else
    get '/*path', to: 'home#index'
  end
  root            to: 'home#index'


  # Helpers for Polymer and External Routes

  scope controller:'none', action:'none' do

    get 'review/:identifier',                                            as: 'paper_review'
    get '/:uid',                host: 'orcid.org',  only_path: false,    as: 'orcid_account'

  end

end
