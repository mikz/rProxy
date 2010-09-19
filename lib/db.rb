require 'dm-core'
require 'dm-constraints'
require 'dm-validations'
 
require "logger"

content = File.new("config/database.yml").read
settings = HashWithIndifferentAccess.new(YAML::load(content))

DataMapper::Logger.new($stdout, :debug)
settings =  settings[RProxy::Server.environment]
#adapter = DataMapper.setup(:default, 'postgres://postgres@localhost/rproxy_sinatra')
DB = DataMapper.setup(:default, settings)

require "app/models/user"
