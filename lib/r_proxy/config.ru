# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../lib/r_proxy', __FILE__)

#use Rack::FiberPool
run RProxy::Server
