class UsersController < ApplicationController
  respond_to :json
  before_filter :require_user, :except => [ :get_current_user ]

  def show
    user = User.find_by_sha(params[:id])
    render :json => user
  end

  def get_current_user
    if current_user
      respond_with current_user
    else
      render :json => {}
    end
  end

  def name_lookup
    guess = params["guess"]
    users = User.where("sha like ?", "%#{guess}%").to_a
    respond_with users
  end
end
