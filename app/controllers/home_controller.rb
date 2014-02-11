class HomeController < ApplicationController
  before_filter :require_user, :except => :show
  
  def index
    
  end
end
