class Api::V1::AnnotationsController < Api::V1::ApplicationController

  respond_to :json
  before_filter :require_user,     except: [:index, :all]
  before_filter :require_editor,   only:   [:update]

  # Root issues
  def index
    if can? :view_annotations, paper
      render json: paper.issues
    else
      render json: [], status: :no_content
    end
  end

  # All issues
  def all
    if can? :view_annotations, paper
      render json: paper.annotations
    else
      render json: [], status: :no_content
    end
  end

  def create
    authorize! :annotate, paper
    render_error(:unprocessable_entity) unless paper.under_review?

    assignment = paper.assignments.for_user(current_user)
    annotation = paper.annotations.build(annotation_params.merge(assignment: assignment))

    if annotation.save
      render json:annotation, status: :created
    else
      render_errors(annotation)
    end
  end

  # def update
  #   # There is no update code here!
  #   if annotation.save
  #     render :json => annotation, :status => :created
  #   else
  #     render :json => annotation.errors, :status => :unprocessable_entity
  #   end
  # end

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
    ability = ability_with(current_user, paper, annotation)
    ability.authorize!(event, annotation)

    render_error(:unprocessable_entity) unless annotation.send("may_#{event}?")

    annotation.send("#{event}!")
    render json: annotation

  rescue AASM::InvalidTransition
    render_error :unprocessable_entity
  end

  def annotation_params
    params.require(:annotation).permit(:body, :parent_id, :page, :xStart, :yStart, :xEnd, :yEnd)
  end

  def annotation
    @annotation ||= paper.annotations.find( params[:id] )
  end

  def paper
    @paper ||= Paper.for_identifier!( params[:paper_identifier] )
  end

end
