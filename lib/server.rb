require 'uri'
require "lib/partials"

Dir[File.join("app", "helpers", "*.rb")].each do |helper|
  require helper
end

SinatraMore::WardenPlugin::PasswordStrategy.user_class = User

class RProxy::Server < Sinatra::Base
  register Sinatra::Async
  register SinatraMore::WardenPlugin
  
  use Rack::Flash
  
  helpers Sinatra::Partials
  include SinatraHelpers
  
  TYPHOEUS_OPTIONS = {
    :follow_location => true,
    :max_redirects => 5,
#      :timeout => 60*100, # 60 seconds
    :cache_timeout => 15*60 # 15 minutes
    
  }
  HYDRA_OPTIONS = {
    :max_concurency => 50
  }
  
  HYDRA = init_hydra HYDRA_OPTIONS
end

HYDRA = RProxy::Server::HYDRA

Warden::Manager.serialize_from_session { |id|  id.nil? ? nil : SinatraMore::WardenPlugin::PasswordStrategy.user_class[id] }

Dir[File.join("app", "controllers", "*.rb")].each do |controller|
  require controller
end
