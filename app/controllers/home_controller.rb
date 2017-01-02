class HomeController < ApplicationController

  def index
  end

  def temp_home
    render :temp_home, :layout => 'temp_home'
  end
end
