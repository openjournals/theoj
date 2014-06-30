class PapersController < ApplicationController
  respond_to :json
  
  def index
    authorize! :index, Paper
    if current_user
      papers = Paper.for_user(current_user)
    else
      papers = { papers: [] }
    end
    respond_with papers
  end

  def show
    paper = Paper.find_by_sha(params[:id])
    ability = ability_with(current_user, paper)
    
    raise CanCan::AccessDenied if ability.cannot? :show, paper
    
    respond_with paper
  end

  def create
    paper = Paper.new(paper_params)
    paper.user = current_user
    authorize! :create, paper

    if paper.save
      render :json => paper, :status => :created, :location => url_for(paper)
    else
      render :json => paper.errors, :status => :unprocessable_entity
    end
  end

  def status
    @paper = Paper.find_by_sha(params[:id])
    etag(params.inspect, @paper.state)

    #TODO replace this with some fancy badge thing.
    render :layout => false
  end
  
  def accept
    paper = Paper.find_by_sha(params[:id])
    authorize! :accept, paper

    if paper.accept!
      render :json => paper, :location => url_for(paper)
    else
      render :json => paper.errors, :status => :unprocessable_entity
    end
  end
  
  def assign_reviewer
    paper = Paper.find_by_sha(params[:id])

    user  = User.find_by_sha(params[:user_name])

    if user && paper.assign_reviewer(params["user_name"])
      render :json => paper, :status => :created, :location => url_for(paper)
    else
      render :json => paper.errors, :status => :unprocessable_entity
    end
  end

  def update
    paper = Paper.find_by_sha(params[:id])
    ability = ability_with(current_user, paper)
    
    raise CanCan::AccessDenied if ability.cannot?(:update, paper)

    if paper.update_attributes(paper_params)
      render :json => paper, :location => url_for(paper)
    else
      render :json => paper.errors, :status => :unprocessable_entity
    end
  end

  def remove_reviewer
    paper = Paper.find_by_sha(params[:id])
    user  = User.find_by_sha(params[:user_name])
    paper.remove_reviewer user
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

  private

  def paper_params
    params.require(:paper).permit(:title, :location)
  end
end
