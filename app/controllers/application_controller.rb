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

  #@todo #@mro - Remove this and replace with Provider::DocumentNotFound
  rescue_from  Arxiv::Error::ManuscriptNotFound   do render_error_internal(:not_found) end
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

  #@mro - needs to be rewritten (should be editor of Paper)
  def require_editor
    render_error :forbidden unless (current_user && current_user.editor?)
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

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
