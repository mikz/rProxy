require 'rubygems'
require "bundler/setup"

require 'active_support/core_ext/object/blank'

ENV["RACK_ENV"] = "development" if ENV["RACK_ENV"].blank?
Bundler.require :default, ENV["RACK_ENV"]

require "lib/debugging"

APP_ROOT = File.dirname(File.dirname(__FILE__) + "..")

module RProxy
  class Server < Sinatra::Base
    set :environment, ENV["RACK_ENV"].to_sym
    
    enable :show_exceptions
    enable :sessions
    set :haml, {:format => :xhtml, :encoding => 'UTF-8'}
    set :public, File.join(APP_ROOT, "public")
    set :views, File.join(APP_ROOT, "app", "views")
    
    configure :production do
      disable :run, :reload
    end
  end
end
