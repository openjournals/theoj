require 'open-uri'

class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.from_omniauth(env["omniauth.auth"])

    #FIXME this needs to go in a worker (or better still, come back in the OAuth hash...)
    name = orcid_name_for(user.uid)
    user.update_attributes(:name => name)

    session[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!"
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
  
  def orcid_name_for(orcid_id)
    data = JSON.parse(open("http://pub.orcid.org/v1.1/#{orcid_id}/orcid-bio", "Accept" => "application/orcid+json").read)
    given_name = data['orcid-profile']['orcid-bio']['personal-details']['given-names']['value']
    surname = data['orcid-profile']['orcid-bio']['personal-details']['family-name']['value']
    
    return "#{given_name} #{surname}"
  end
end
