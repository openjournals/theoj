class UsersController < ApplicationController
  respond_to :json
  before_filter :require_user,   except: [ :show ]
  before_filter :require_editor, only:   [ :lookup ]

  def show
    if current_user
      respond_with current_user, serializer:AuthenticatedUserSerializer
    else
      render :json => {}
    end
  end

  def update
    if current_user.update_attributes(update_params)
      render json:current_user, serializer:AuthenticatedUserSerializer
    else
      render_errors(current_user)
    end
  end

  def lookup
    guess = params["guess"]
    users = User.where("name like ?", "%#{guess}%").order(:name).limit(20)
    respond_with users, each_serializer:PublicUserSerializer
  end

  private

  def update_params
    params.require(:user).permit(:email)
  end

end
