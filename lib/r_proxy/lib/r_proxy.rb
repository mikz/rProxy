require "uri"
require "sinatra/async"
require "typhoeus"
require "ezcrypto"
require "open3"
module RProxy
  mattr_accessor :plugins
  @@plugins = []
  
  mattr_reader :plugin_class
  @@plugin_class = "Plugin::Base"
  
  mattr_accessor :user_class
  @@user_class = '::User'
  
  autoload :Plugin, "r_proxy/plugin"
  autoload :User,   "r_proxy/user"
  autoload :Worker, "r_proxy/worker"
  autoload :XMLProcessor, "r_proxy/xml_processor"
  autoload :Server, "r_proxy/server"
  autoload :Ruby, "r_proxy/ruby"
  
  def self.user_model
    user_class.constantize
  end
  
  def self.plugin_model
    plugin_class.constantize
  end
end

require "r_proxy/rails"