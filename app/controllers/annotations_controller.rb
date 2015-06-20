class AnnotationsController < ApplicationController
  before_filter :find_paper
  before_filter :require_user
  before_filter :require_editor,   only:[:update]
  before_filter :find_annotation,  only:[:update, :unresolve, :dispute, :resolve]

  def index
    render :json => @paper.annotations
  end

  def issues
    render :json => @paper.issues
  end

  def create
    authorize! :annotate, @paper
    render_error(:unprocessable_entity) unless @paper.under_review?

    assignment = @paper.assignments.for_user(current_user)
    annotation = @paper.annotations.build(annotation_params.merge(assignment: assignment))

    if annotation.save
      render json:annotation, status: :created
    else
      render_errors(annotation)
    end
  end

  def update
    # There is no update code here!
    if @annotation.save
      render :json => @annotation, :status => :created
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

    render_error(:unprocessable_entity) unless @annotation.send("may_#{event}?")

    @annotation.send("#{event}!")
    render json:@annotation

  rescue AASM::InvalidTransition
    render_error :unprocessable_entity
  end

  def annotation_params
    params.require(:annotation).permit(:body, :parent_id, :page, :xStart, :yStart, :xEnd, :yEnd)
  end

  def find_paper
    @paper ||=  Paper.find_by_sha(params[:paper_id])
    render_error(:not_found) unless @paper
  end

  def find_annotation
    find_paper
    @annotation ||= @paper.annotations.find( params[:id] )
    render_error(:not_found) unless @annotation
  end

end
