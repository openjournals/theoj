class UsersController < ApplicationController
  def show
    user = User.find_by_sha(params[:id])
    render :json => user
  end
end
