class UsersController < ApplicationController
  respond_to :json
  def show
    user = User.find(params[:id])
    render :json => user
  end

  def get_current_user
    respond_with current_user
  end
end
