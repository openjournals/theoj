class HomeController < ApplicationController

  def index
  end

  def temp_home
    @papers = Paper.published
    render :temp_home, :layout => 'temp_home', :papers => @papers
  end
end
