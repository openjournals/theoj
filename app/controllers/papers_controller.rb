class PapersController < ApplicationController
  def index
    papers = Papers.for_user(current_user)
  end

  def show
    paper = Paper.find(params[:id])
    render :json => paper, :include => paper.annotations
  end

  def create
    paper = Paper.new(params[:paper])

    if paper.save
      render :json => paper, :status => :created, :location => url_for(paper)
    else
      render :json => paper.errors, :status => :unprocessable_entity
    end
  end
end
