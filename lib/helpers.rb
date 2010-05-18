#require "active_support/cache"

module SinatraHelpers
  
#  CACHE = ActiveSupport::Cache::MemoryStore.new
  
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
  
  def aredirect url, status = 302
    response.status = status
    response.headers['Location'] = url
    body ''
  end
end