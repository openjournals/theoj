class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  # before_filter :require_user

  class HttpError < StandardError
    def initialize(status_code, text)
      @status_code, @text, @message = status_code, text
    end
    attr_reader :status_code, :text
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render :json => {}, :status => :forbidden }
    end
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
  end

  rescue_from  Provider::Error::ProviderNotFound  do render_error_internal(:not_found) end
  rescue_from  Provider::Error::DocumentNotFound  do render_error_internal(:not_found) end
  rescue_from  Provider::Error::InvalidIdentifier do render_error_internal(:bad_request) end
  rescue_from  ActiveRecord::RecordNotFound       do render_error_internal(:not_found) end
  rescue_from  ActiveRecord::RecordNotUnique      do render_error_internal(:conflict) end
  rescue_from  HttpError                          do |ex| render_error_internal(ex.status_code, ex.text) end

  private

  def ability_with(user, paper=nil, annotation=nil)
    Ability.new(user, paper, annotation)
  end

  def require_user
    render_error :unauthorized unless current_user
  end

  def require_paper_editor_or_admin
    paper = Paper.for_identifier( params[:identifier] )
    render_error :forbidden unless current_user && (current_user.editor_of?(paper) || current_user.admin?)
  end

  #@mro, @todo - needs to be rewritten (should be editor of Paper)
  def require_editor
    render_error :forbidden unless current_user && current_user.editor?
  end

  def require_admin
    render_error :forbidden unless current_user && current_user.admin?
  end

  def current_user
    if !defined?(@current_user) && session[:user_id] && session[:user_sha]
      user = User.find(session[:user_id])
      @current_user = user.sha == session[:user_sha] ? user : nil
    end
    @current_user
  end
  helper_method :current_user

  def signed_in?
    current_user.present?
  end
  helper_method :signed_in?

  def authentication_required
    return if signed_in?

    respond_to do |format|
      format.html  {
        url = '/auth/orcid?origin=' + CGI.escape(request.url)
        redirect_to url, status: :forbidden
      }
      format.json {
        render json: { error: 'Access Denied' }, status: :forbidden
      }
    end
  end

  def render_error_internal(status_code, text=nil)
    code    = Rack::Utils::SYMBOL_TO_STATUS_CODE[status_code]
    message = "#{code} #{Rack::Utils::HTTP_STATUS_CODES[code]}"

    respond_to do |format|
      format.html { render plain:text || message, status: status_code }
      format.json { render json: {error:message, text:text, code:code}, status: status_code }
    end
  end

  def render_error(status_code, text=nil)
    # raise here so that we break out of any processing
    raise HttpError.new(status_code, text)
  end

  def render_errors(object, status_code=:unprocessable_entity)
    render_error(status_code, object.errors.full_messages.join(".\r\n") + "." )
  end

end
