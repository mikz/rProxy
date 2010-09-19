require 'nokogiri'
require 'digest/sha2'
require 'ezcrypto'
#require 'base32'
require "openssl"
require 'open-uri'
require "ruby-debug"

require "lib/debugging"

require "lib/db"

module Plugin
  LIST = []
end

module RProxy
  class Plugin
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :class_name, String, :required => true
    property :name, String, :required => true
    property :url, String, :length => 255, :required => true
    property :active, Boolean, :required => true, :default => false

    TOKEN_DELIM = "."
    def url_for_user user
      user.encrypt_url self.id, self.url
    end
    
    def get_token key
      tokens = key.split(TOKEN_DELIM)
      case tokens.shift.to_sym
      when :config
        config(tokens.join(TOKEN_DELIM))
      end
      
    end
    
    def config key, user = self.user
      config = user.get_config(self, key)
      config ? config.value : nil
    end
    
    class << self
      
      def inherited(subclass)
        super
        ::Plugin::LIST << subclass
      end
      
      def with_class id
        record = self.get id
        klass = record.class_name.constantize
        klass.get id
      end
    end
  end
end

require "lib/worker"
require "lib/ruby"

Dir["plugins/*.rb"].each do |plugin|
  require plugin
end

Plugin::LIST.each do |plugin|
  unless RProxy::Plugin.first(:name => plugin.name)
    RProxy::Plugin.create :class_name => plugin.to_s, :name => plugin.name, :url => plugin.url
  end if DB.storage_exists?(plugin.storage_name)
end

