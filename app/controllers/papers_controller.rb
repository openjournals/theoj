class PapersController < ApplicationController
  respond_to :json
  before_filter :require_user,   except: [ :state, :index ]
  before_filter :require_editor, only:   [ :transition ]

  def index
    if current_user
      as_author
    else
      papers = []
      respond_with papers
    end
  end

  def show
    paper = Paper.find_by_sha(params[:id])
    ability = ability_with(current_user, paper)

    raise CanCan::AccessDenied if ability.cannot? :show, paper

    respond_with paper
  end

  def arxiv_details
    id = params[:id]
    existing = Paper.find_by_arxiv_id(id)

    if existing
      respond_with existing, serializer:ArxivSerializer

    else
      data = Arxiv.get(id)
      respond_with data
    end
  end

  def create
    paper = Paper.new_for_arxiv_id(params[:arxiv_id], submittor:current_user)
    authorize! :create, paper

    if paper.save
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

  def state
    @paper = Paper.find_by_sha(params[:id])
    if @paper
      etag(params.inspect, @paper.state)
    else
      etag(params.inspect, "unknown")
    end

    render :layout => false
  end

  def transition
    paper = Paper.find_by_sha(params[:id])
    transition = params[:transition].to_sym

    authorize! transition, paper

    if paper.aasm.may_fire_event?(transition)
      paper.send("#{transition.to_s}!")
      render :json => paper, :location => url_for(paper)

    else
      render :json => paper.errors, :status => :unprocessable_entity
    end
  end

  def check_for_update
    arxiv_id = params[:id]
    latest_paper = Paper.where(arxiv_id:arxiv_id).order(version: :desc).first

    render_error(:not_found)    and return unless latest_paper
    render_error(:forbidden)    and return unless latest_paper.submittor == current_user
    render_error(:conflict)     and return unless latest_paper.may_supercede?

    arxiv_doc = Arxiv.get(arxiv_id)

    render_error(:conflict, 'There is no new version of this document.') and return unless arxiv_doc.version > latest_paper.version

    new_paper = Paper.create_updated!(latest_paper, arxiv_doc)

    render json:new_paper, status: :created
  end

  def as_reviewer
    papers = current_user.papers_as_reviewer.active.with_state(params[:state])
    respond_with papers
  end

  def as_editor
    papers = current_user.papers_as_editor.active.with_state(params[:state])
    respond_with papers
  end

  def as_author
    papers = current_user.papers_as_submittor.active.with_state(params[:state])
    respond_with papers
  end

  def as_collaborator
    papers = current_user.papers_as_collaborator.active.with_state(params[:state])
    respond_with papers
  end

  private

  def paper_params
    params.require(:paper).permit(:title, :location)
  end

end
