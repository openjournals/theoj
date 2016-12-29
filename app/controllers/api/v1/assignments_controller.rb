class Api::V1::AssignmentsController < Api::V1::ApplicationController

  respond_to :json
  before_filter :require_user,   except: [ :index ]
  before_filter :require_editor, only:   [ :create, :destroy ]

  def index
    render json:paper.assignments, status: :ok, location: paper_review_url(paper)
  end

  def create
    user  = User.find_by_sha(params[:user])
    role  = params[:role] || 'reviewer'

    if !paper.submitted? && !paper.under_review?
      render json: 'invalid state', status: :bad_request

    elsif role != 'reviewer' && role != 'collaborator'
      render json: 'invalid role', status: :bad_request

    elsif user && paper.add_assignee(user, role)
      paper.start_review! unless paper.under_review?
      render json: paper.assignments, status: :created, location: paper_review_url(paper)

    else
      render json: paper.errors, status: :unprocessable_entity

    end
  end

  def destroy
    if assignment && assignment.destroy
      render json:paper.assignments, status: :ok, location: paper_review_url(paper)
    else
      render json: paper.errors, status: :unprocessable_entity
    end
  end

  private

  def assignment
    @assignment ||= paper.assignments.find_by_sha(params[:id])
  end

  def paper
    @paper ||= Paper.for_identifier!( params[:paper_identifier] )
  end

end