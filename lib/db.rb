require 'dm-core'
require 'dm-constraints'
require 'dm-validations'
 
require "logger"

DataMapper::Logger.new($stdout, :debug)
#adapter = DataMapper.setup(:default, 'postgres://postgres@localhost/rproxy_sinatra')
adapter = DataMapper.setup :default, {:adapter => "postgres", :username => "postgres", :hostname => "localhost", :database => "rproxy_sinatra", :encoding => "UTF-8"}
require "lib/models/user"
require "lib/models/data"
require "lib/models/config"



