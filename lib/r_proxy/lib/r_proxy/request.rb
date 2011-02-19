module RProxy
  
  class Request
    TYPHOEUS_OPTIONS = {
      :follow_location => true,
      :max_redirects => 5,
      :cache_timeout => 15.minutes,
      :verbose => true
    }
    HYDRA_OPTIONS = {
      :max_concurency => 50
    }

    HYDRA = Typhoeus::Hydra.new HYDRA_OPTIONS
    
    attr_reader :location
    attr_reader :plugin
    
    def initialize query, method
      super
      
      @query = query
      decrypted = RProxy.user_model.decrypt_url(query)

      @plugin = decrypted[:plugin]
      @user = decrypted[:user]
      @url = URI.parse((decrypted[:url])? decrypted[:url] : decrypted[:plugin].url)
      
      @method = method
    end
    
    def process(current_url, params)
      @result = nil
      params.delete(@query)
      
      @current_url =  URI.parse current_url
      options = TYPHOEUS_OPTIONS.merge(:method => @method).merge(@plugin.options)
      options.merge! :params => params unless params.empty?
      request = Typhoeus::Request.new(@url.to_s, options)

      request.on_complete do |response|

        if @location = response.headers_hash['Location'].presence
          @location = @url.merge(URI.parse @location)
        end

        content_type = response.headers_hash['Content-Type']
        encoding = (content_type.blank?) ? nil : content_type.split(";").last.split("=").last

        @plugin.process response.body, @user, @url, URI.parse(current_url.to_s), encoding
      end
      
      HYDRA.queue request
      
      HYDRA.run
      
      @plugin.output
    end
    
    def redirected?
      @location.present?
    end
    
    def location
      @plugin.path(@location, @user)
    end
    
    class << self
      [:post, :get].each do |method|
        define_method method do |query|
          self.new(query, method)
        end
      end
    end
  end
end