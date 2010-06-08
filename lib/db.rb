require 'dm-core'
require 'dm-constraints'
require 'dm-validations'
 
require "logger"

content = File.new("config/database.yml").read
settings = YAML::load content

DataMapper::Logger.new($stdout, :debug)


DEBUG {%w{settings}}
configure :production do 
  settings = settings["production"]
end

configure :development do 
  settings = settings["development"]
end
#adapter = DataMapper.setup(:default, 'postgres://postgres@localhost/rproxy_sinatra')
adapter = DataMapper.setup :default, settings

require "lib/models/user"
require "lib/models/data"
require "lib/models/config"



