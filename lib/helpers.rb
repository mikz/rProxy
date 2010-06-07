#require "active_support/cache"
require "lib/partials"

module SinatraHelpers
  
#  CACHE = ActiveSupport::Cache::MemoryStore.new
  def self.included(base)
    base.send :extend, ClassMethods
    base.class_eval %{}
    base.helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def aredirect url, status = 302
        response.status = status
        response.headers['Location'] = url
        body ''
      end
    end
  end
  module ClassMethods
    def init_hydra options = {}
      hydra = Typhoeus::Hydra.new options
  #    hydra.cache_setter do |request|
  #      DEBUG {%w{request.cache_key request.response}}
  #      CACHE.write request.cache_key, request.response, :expires_in => request.cache_timeout
  #    end
  #    hydra.cache_getter do |request|
  #      DEBUG {%w{request.cache_key}}
  #      CACHE.read(request.cache_key) rescue nil
  #    end
      hydra
    end
  end
  
end