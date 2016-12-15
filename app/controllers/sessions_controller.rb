require 'open-uri'

class SessionsController < ApplicationController

  def new
  end

  def create
    logger.debug("#create")
    user = User.from_omniauth(env["omniauth.auth"])

    #FIXME this needs to go in a worker (or better still, come back in the OAuth hash...)
    name = orcid_name_for(user.uid)
    user.update_attributes(:name => name)

    session[:user_id]  = user.id
    session[:user_sha] = user.sha
    redirect_to root_url, :notice => "Signed in!"
  end
  
  def destroy
    session[:user_id]  = nil
    session[:user_sha] = nil
    redirect_to root_url, :notice => "Signed out!"
  end

  def failure
    message = if params[:message]
                "You could not be logged in! (#{params[:message].humanize})"
              else
                "You could not be logged in!"
              end

   redirect_to root_url, :alert => message
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  #@todo refactor this into a class
  def orcid_name_for(orcid_id)
    uri  = "https://pub.orcid.org/v1.1/#{orcid_id}/orcid-bio"
    logger.debug("URI: #{uri.inspect}")
    raw  = open(uri, "Accept" => 'application/orcid+json') { |f| f.read }
    data = JSON.parse(raw)
    given_name = data['orcid-profile']['orcid-bio']['personal-details']['given-names']['value']
    surname    = data['orcid-profile']['orcid-bio']['personal-details']['family-name']['value']
    
    "#{given_name} #{surname}"
  end
end
