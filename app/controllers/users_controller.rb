class UsersController < ApplicationController
  def show
    user = User.find(:sha => params[:id])
    render :json => user
  end
end
