require 'rubygems'
require "bundler"
Bundler.setup

require 'async-rack'

Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'


require "lib/debugging"

require "sinatra"


set :env, (env = ENV["RACK_ENV"])? env : 'development'

configure :production do
  disable :run, :reload
end


require "lib/plugin"


require "lib/server"

require 'lib/inflections'



