#@toto #@mro - Validate format of identifiers

class PapersController < ApplicationController
  respond_to :json
  before_filter :require_user,   except: [ :state, :index, :versions ]
  before_filter :require_editor, only:   [ :destroy, :transition ]

  def index
    if current_user
      as_author
    else
      papers = []
      respond_with papers
    end
  end

  def show
    ability = ability_with(current_user, paper)
    raise CanCan::AccessDenied if ability.cannot? :show, paper

    respond_with paper, serializer:FullPaperSerializer
  end

  #@mro #@todo n- rename this in Polymer
  def arxiv_details
    begin
      existing = paper
      respond_with existing, serializer:ArxivSerializer

    rescue ActiveRecord::RecordNotFound

      data = Arxiv.get(id)
      respond_with data

    end
  end

  #@mro #@todo rewrite this to use full ids
  def create
    paper = Paper.new_for_arxiv_id(params[:arxiv_id], submittor:current_user)
    authorize! :create, paper

    if paper.save
      render json:paper, status: :created, location:paper_review_url(paper), serializer:FullPaperSerializer
    else
      render json:aper.errors, status: :unprocessable_entity
    end
  end

  def update
    ability = ability_with(current_user, paper)
    raise CanCan::AccessDenied if ability.cannot?(:update, paper)

    if paper.update_attributes(paper_params)
      render json:paper, location:paper_review_url(paper), serializer:FullPaperSerializer
    else
      render json:paper.errors, status: :unprocessable_entity
    end
  end

  def destroy
    render_error(:unprocessable_entity) unless paper.can_destroy?

    ActiveRecord::Base.transaction do
      has_errors = false

      paper.all_versions.each do |p|
        p.destroy
        has_errors ||= p.errors.present?
      end

      if has_errors
        render_errors paper
      else
        render json:{}
      end

    end

  end

  def state
    if stale?(paper)

      respond_to do |format|
        format.html { @paper = paper; render layout:false }
        format.json { render json: {  state: paper.state } }
      end

    end
  end

  def transition
    transition = params[:transition].to_sym
    authorize! transition, paper

    if paper.aasm.may_fire_event?(transition)
      paper.send("#{transition.to_s}!")
      render json:paper, location:paper_review_url(paper), serializer:FullPaperSerializer

    else
      render_errors(paper)
    end
  end

  def complete
    authorize! :complete, paper

    if paper.mark_review_completed!(current_user)
      paper.assignments.reload
      render json:paper, location:paper_review_url(paper), serializer:FullPaperSerializer
    else
      render_errors(paper)
    end
  end

  def public
    authorize! :make_public, paper

    case request.method_symbol

      when :post, :delete
        public = request.method_symbol != :delete
        if paper.make_reviewer_public!(current_user, public)
          paper.assignments.reload
          render json:paper, location:paper_review_url(paper), serializer:FullPaperSerializer
        else
          render_errors(assignment)
        end

      else
        raise 'Unsupported method'

    end

  end

  def versions
    provider_type, provider_id, version = Provider.parse_identifier( params[:identifier] )
    papers   = Paper.versions_for( provider_type, provider_id )
    render json:papers, each_serializer: BasicPaperSerializer
  end

  def check_for_update
    latest_paper = paper

    render_error(:not_found)    unless latest_paper
    render_error(:forbidden)    unless latest_paper.submittor == current_user
    render_error(:conflict)     unless latest_paper.may_supercede?

    provider = latest_paper.provider
    document_attributes = provider.get_attributes(latest_paper.provider_id)

    render_error(:conflict, 'There is no new version of this document.') unless document_attributes[:version] > latest_paper.version

    new_paper = latest_paper.create_updated!(document_attributes)

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

  def paper
    @paper ||= Paper.for_identifier( params[:identifier] )
  end

end
