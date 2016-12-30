class PapersController < ApplicationController
  respond_to :json

  def badge
    if stale?(paper)

      respond_to do |format|
        format.html { @paper = paper; render layout:false }
        format.json { render json: {  state: paper.state } }
      end

    end
  end

  private

  def paper
    @paper ||= Paper.for_identifier!( params[:identifier] )
  end

end
