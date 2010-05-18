require 'nokogiri'
require 'digest/sha2'
require 'ezcrypto'
#require 'base32'
require "openssl"
require "sequel"
require 'open-uri'
require "ruby-debug"

require "sinatra"

require "debugging"

require "lib/db"

module Plugin
end

module RProxy
  class Plugin < Sequel::Model(:plugins)
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
    
    def config key
      config = user.get_config(self, key)
      config ? config.value : nil
    end
    
    class << self
      def with_class id
        record = self[id]
        klass = record.class_name.split('::').reduce(Object){|cls, c| cls.const_get(c) }
        klass[id]
      end
    end
  end
end

require "lib/worker"

Dir["plugins/*.rb"].each do |plugin|
  require plugin
end