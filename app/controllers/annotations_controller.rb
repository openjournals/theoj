class AnnotationsController < ApplicationController
  before_filter :find_paper
  before_filter :require_user

  def index
    render :json => @paper.annotations
  end

  def issues
    render :json => @paper.issues, each_serializer: IssuesSerializer
  end

  def create
    annotation = @paper.annotations.new(annotation_params.merge(user_id: current_user.id))

    if @paper.annotations << annotation
      render :json => annotation, :status => :created, serializer: IssuesSerializer
    else
      render :json => annotation.errors, :status => :unprocessable_entity
    end
  end

  def update
    annotation = Annotation.find(params[:id])

    # TODO should we be using the @paper object here?
    if annotation.save
      render :json => annotation, :status => :created, serializer: IssuesSerializer
    else
      render :json => annotation.errors, :status => :unprocessable_entity
    end
  end

  private

  def annotation_params
    params.require(:annotation).permit(:body, :parent_id, :page, :xStart, :yStart, :xEnd, :yEnd)
  end

  def find_paper
    @paper =  Paper.find_by_sha(params[:paper_id])
  end
end
