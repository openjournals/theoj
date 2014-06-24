class UsersController < ApplicationController
  respond_to :json

  def show
    user = User.find_by_sha(params[:id])
    render :json => user
  end

  def get_current_user
    respond_with current_user
  end

  def name_lookup
    guess = params["guess"]
    users = User.where("sha like ?", "%#{guess}%").select(:sha, :id).to_a
    respond_with users
  end
end
