class PapersController < ApplicationController
  def index
    papers = Papers.for_user(current_user)
  end
  
  def show
    paper = Paper.find(params[:id])
    render :json => paper
  end
end
