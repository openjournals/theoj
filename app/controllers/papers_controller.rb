
class PapersController < ApplicationController
  respond_to :json

  def index
    papers = Paper.for_user(current_user)
    respond_with papers
  end

  def show
    paper = Paper.find_by_sha(params[:id])
    respond_with paper
  end

  def create
    paper = Paper.new(params[:paper])

    if paper.save
      render :json => paper, :status => :created, :location => url_for(paper)
    else
      render :json => paper.errors, :status => :unprocessable_entity
    end
  end

  def as_reviewer
    papers = current_user.papers_as_reviewer
    render :json => papers
  end

  def as_editor
    papers = current_user.papers_as_editor
    render :json => papers
  end

  def as_author
    papers = current_user.papers
    render :json => papers
  end

  def as_collaborator
    papers = current_user.papers_as_collaborator
    render :json => papers
  end
end
