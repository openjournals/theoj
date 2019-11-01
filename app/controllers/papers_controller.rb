class PapersController < ApplicationController
  respond_to :json

  before_filter :require_paper_editor_or_admin, only: [ :history ]

  def badge
    if stale?(paper)

      respond_to do |format|
        format.html { @paper = paper; render layout:false }
        format.json { render json: {  state: paper.state } }
      end

    end
  end

  def history
    @paper = paper
  end

  private

  def paper
    @paper ||= Paper.for_identifier!( params[:identifier] )
  end

end
