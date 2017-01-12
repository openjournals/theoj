class HomeController < ApplicationController

  before_filter :authentication_required, only: [:index_with_auth]

  def index
    render :index
  end

  def index_with_auth
    render :index
  end

  def temp_home
    papers = Paper.published
    render 'temp_home', locals: { papers: papers }
  end

end
