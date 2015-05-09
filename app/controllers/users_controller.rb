class UsersController < ApplicationController
  respond_to :json
  before_filter :require_user,   except: [ :get_current_user ]
  before_filter :require_editor, only:   [ :name_lookup ]

  def show
    user = User.find_by_sha(params[:id])
    render :json => user, serializer:AnonymousUserSerializer
  end

  def get_current_user
    if current_user
      respond_with current_user, serializer:AuthenticatedUserSerializer
    else
      render :json => {}
    end
  end

  def name_lookup
    guess = params["guess"]
    users = User.where("name like ?", "%#{guess}%").order(:name).limit(20)
    respond_with users, each_serializer:PublicUserSerializer
  end

end
