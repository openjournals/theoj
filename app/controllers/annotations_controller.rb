class AnnotationsController < ApplicationController
  before_filter :find_paper
  
  def index
    render :json => @paper.annotations
  end
  
  def create
    annotation = Annotation.new(params[:annotation])
    if @paper.annotations << annotation
      render :json => { }, :status => 201
    else
      render :json => annotation.errors
    end
  end
  
  private
  
  def find_paper
    @paper = Paper.find(params[:paper_id])
  end
end
