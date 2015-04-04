class UsersController < ApplicationController
  respond_to :json
  before_filter :require_user, :except => [ :get_current_user ]

  def show
    user = User.find_by_sha(params[:id])
    render :json => user, serializer: UserWithPapersSerializer
  end

  def get_current_user
    if current_user
      respond_with current_user, serializer: UserWithPapersSerializer
    else
      render :json => {}
    end
  end

  def name_lookup
    guess = params["guess"]
    users = User.where("name like ?", "%#{guess}%")
    respond_with users
  end

end
