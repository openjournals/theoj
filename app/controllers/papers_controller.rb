class PapersController < ApplicationController
  before_filter :require_user
  
  def show
    @paper = Paper.find(params[:id])
  end
end
