class CommentsController < ApplicationController
  before_filter :find_paper
  
  def index
    render :json => @paper.comments
  end
  
  def create
    comment = Comment.new(params[:comment])
    if @paper.comments << comment
      render :json => { }, :status => 201
    else
      render :json => comment.errors
    end
  end
  
  private
  
  def find_paper
    @paper = Paper.find(params[:paper_id])
  end
end
