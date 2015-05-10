class AnnotationsController < ApplicationController
  before_filter :find_paper
  before_filter :require_user
  before_filter :require_editor,   only:[:update]
  before_filter :find_annotation,  only:[:update, :unresolve, :dispute, :resolve]

  def index
    render :json => @paper.annotations
  end

  def issues
    render :json => @paper.issues, each_serializer: IssueSerializer
  end

  def create
    annotation = @paper.annotations.new(annotation_params.merge(user_id: current_user.id))

    if @paper.annotations << annotation
      render :json => annotation, :status => :created, serializer: IssueSerializer
    else
      render :json => annotation.errors, :status => :unprocessable_entity
    end
  end

  def update
    # There is no update code here!
    if @annotation.save
      render :json => @annotation, :status => :created, serializer: IssueSerializer
    else
      render :json => @annotation.errors, :status => :unprocessable_entity
    end
  end

  def unresolve
    change_state(:unresolve)
  end

  def dispute
    change_state(:dispute)
  end

  def resolve
    change_state(:resolve)
  end

  private

  def change_state(event)
    ability = ability_with(current_user, @paper, @annotation)
    ability.authorize!(event, @annotation)

    @annotation.send("#{event}!")
    render :json => @annotation, serializer: IssueSerializer

  rescue AASM::InvalidTransition
    render_error :unprocessable_entity
  end

  def annotation_params
    params.require(:annotation).permit(:body, :parent_id, :page, :xStart, :yStart, :xEnd, :yEnd)
  end

  def find_paper
    @paper ||=  Paper.find_by_sha(params[:paper_id])
    record_not_found unless @paper
  end

  def find_annotation
    find_paper
    @annotation ||= @paper.annotations.find( params[:id] )
    record_not_found unless @annotation
  end

end
