class Api::V1::PapersController < Api::V1::ApplicationController

  respond_to :json
  before_filter :require_user,   except: [ :recent, :search, :index, :show, :versions ]
  before_filter :require_editor, only:   [ :destroy, :transition ]

  def index
    recent
  end

  def show
    #@todo
    # ability = ability_with(current_user, paper)
    # raise CanCan::AccessDenied if ability.cannot? :show, paper

    respond_with paper, serializer:FullPaperSerializer
  end

  # Get the details for a new submission
  def preview
    paper = Paper.for_identifier( params[:identifier] )

    if !paper
      document_attributes = Provider.get_attributes( params[:identifier] )
      # Don't save this, just use it to generate some JSON
      paper = Paper.new(document_attributes)
    end

    respond_with paper, serializer:PreviewPaperSerializer
  end

  def create
    document_attributes = Provider.get_attributes( params[:identifier] )
    document_attributes.merge!(submittor:current_user)
    paper = Paper.new(document_attributes)
    authorize! :create, paper

    if paper.save
      render json:paper, status: :created, location:paper_review_url(paper), serializer:PaperSerializer
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

  def badge
    if stale?(paper)

      respond_to do |format|
        format.html { @paper = paper; render layout:false }
        format.json { render json: {  state: paper.state } }
      end

    end
  end

  def transition
    transition = params[:transition].to_sym
    ability_with(current_user, paper).authorize! transition, paper

    if paper.aasm.may_fire_event?(transition)
      paper.send("#{transition.to_s}!")
      render json:paper, location:paper_review_url(paper), serializer:FullPaperSerializer

    else
      render_errors(paper)
    end
  end

  def complete
    render_error(:unprocessable_entity) unless paper.under_review?
    authorize! :complete, paper

    render_error(:bad_request, 'accept parameter not supplied') if params[:result].nil?

    if paper.mark_review_completed!(current_user, params[:result], params[:comments])
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
    parts = Provider.parse_identifier( params[:identifier] )
    papers   = Paper.versions_for( parts[:provider_type], parts[:provider_id] )
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

  def recent
    respond_with_papers Paper.recent.published
  end

  def search
    query = params[:q]
    render_error(:bad_request) unless query.present?

    respond_with_papers Paper.search(query)
  end

  def as_reviewer
    respond_with_papers current_user.papers_as_reviewer
  end

  def as_editor
    respond_with_papers current_user.papers_as_editor
  end

  def as_author
    respond_with_papers current_user.papers_as_submittor
  end

  def as_collaborator
    respond_with_papers current_user.papers_as_collaborator
  end

  private

  def paper_params
    params.require(:paper).permit(:title, :document_location)
  end

  def respond_with_papers(root_relation)
    papers = root_relation.active.with_state(params[:state])
    respond_with papers
  end

  def paper
    @paper ||= Paper.for_identifier!( params[:identifier] )
  end

end
