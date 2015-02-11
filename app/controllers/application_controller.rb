class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  # before_filter :require_user

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render :json => {}, :status => :forbidden }
    end
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
  end

  rescue_from  Arxiv::Error::ManuscriptNotFound, with: :record_not_found

  rescue_from  ActiveRecord::RecordNotUnique do |exception|
      render plain: "409 Conflict", status: :conflict
  end

  private

  def record_not_found
    render plain: "404 Not Found", status: :not_found
  end

  def ability_with(user, paper=nil, annotation=nil)
    Ability.new(user, paper, annotation)
  end

  def etag(params, state)
    etag = Digest::MD5.hexdigest(TheOJVersion + params.inspect + state)
    headers['ETag'] = etag
  end

  def require_user
    render :json => {}, :status => "403" unless current_user
  end

  def require_editor
    render :json => {}, :status => "403" unless (current_user && current_user.editor?)
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
