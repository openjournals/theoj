class AdminController < ApplicationController
  respond_to :json
  layout     false

  before_filter :require_admin

  def index
  end

end
