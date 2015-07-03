require 'active_support/concern'

module ControllerSpecHelpers
  extend ActiveSupport::Concern

  attr_reader :current_user

  def authenticate(user=nil)
    if user.is_a?(Symbol)
      user = create(user)
    elsif user.nil?
      user = create(:user)
    end
    allow(controller).to receive(:current_user).and_return(user)
    @current_user = user
  end

  def not_authenticated!
    allow(controller).to receive(:current_user).and_return(nil)
    @current_user = nil
  end

  def response_json
    @response_json ||= JSON.parse( response.body )
  end

  def error_json(status_code)
    code    = Rack::Utils::SYMBOL_TO_STATUS_CODE[status_code]
    message = "#{code} #{Rack::Utils::HTTP_STATUS_CODES[code]}"
    {"error" => message, "text" => nil, "code" => code}
  end

  # Add default params

  def process_with_default_params(action, method, parameters={}, *rest)
    process_without_default_params(action, method, default_params.merge(parameters || {}), *rest)
  end

  included do
    let(:default_params) { {format:'json'} }
    alias_method_chain :process, :default_params
  end

end
