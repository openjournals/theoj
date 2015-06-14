class AssignmentsController < ApplicationController
  respond_to :json
  before_filter :require_user,   except: [ :index ]
  before_filter :require_editor, only:   [ :create, :destroy ]

  def index
    paper = Paper.find_by_sha(params[:paper_id])
    render json:paper.assignments, status: :ok, location: paper_review_url(paper)
  end

  def create
    paper = Paper.find_by_sha(params[:paper_id])
    user  = User.find_by_sha(params[:user])
    role  = params[:role] || 'reviewer'

    if role != 'reviewer' && role != 'collaborator'
      render :json => 'invalid role', :status => :bad_request

    elsif user && paper.add_assignee(user, role)
      render :json => paper.assignments, :status => :created, :location => paper_review_url(paper)

    else
      render :json => paper.errors, :status => :unprocessable_entity

    end
  end

  def destroy
    paper = Paper.find_by_sha(params[:paper_id])
    assignment = paper.assignments.find_by_sha(params[:id])

    if assignment && assignment.destroy
      render json:paper.assignments, status: :ok, location: paper_review_url(paper)
    else
      render :json => paper.errors, :status => :unprocessable_entity
    end
  end

end
