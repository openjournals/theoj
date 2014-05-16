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
