require 'omniauth-orcid'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :orcid, ENV['ORCID_KEY'], ENV['ORCID_SECRET']
end