module RProxy
  class Server < ::Sinatra::Base
    register ::Sinatra::Async
    
    enable :show_exceptions
    
    TYPHOEUS_OPTIONS = {
      :follow_location => true,
      :max_redirects => 5,
  #      :timeout => 60*100, # 60 seconds
      :cache_timeout => 15*60 # 15 minutes

    }
    HYDRA_OPTIONS = {
      :max_concurency => 50
    }

    ::RProxy::HYDRA = ::Typhoeus::Hydra.new HYDRA_OPTIONS
    
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def aredirect url, status = 302
        response.status = status
        response.headers['Location'] = url
        body ''
      end
      
      def warden
        request.env['warden']
      end
      
      def authenticate_user!(force = false)
        catch(:warden) do
          warden.authenticate!(:scope => :user) || force
        end
      end
      
      def current_user
        @current_user ||= warden.authenticate(:scope => :user)
      end
    end
    
    aget '/delay/:n' do |n|
      EM.add_timer(n.to_i) { body { "delayed for #{n} seconds" } }
    end
    
    post /^\/(.+)/ do |proxy_token|
      authenticate_user!
      
      decrypted = RProxy.user_model.decrypt_url(proxy_token)
    
      url = URI.parse((decrypted[:url])? decrypted[:url] : decrypted[:plugin].url)
      app_path = URI.parse(request.url)

      request = Typhoeus::Request.new(url.to_s, TYPHOEUS_OPTIONS.merge(:method => :post, :params => params))
      request.on_complete do |response|
      
        headers = response.headers.split("\r\n")
        headers.each do |header|
          if header =~ /Location\:\ (.+)$/i
            url = url.merge($1)
          
            @redirect = aredirect("/p/" + current_user.encrypt_url(decrypted[:plugin].id, url))
          
          end
        
        end if headers[2] =~ /302\ Found$/
      
        if !@redirect
          plugin = decrypted[:plugin]
          plugin.process response.body, current_user, url, app_path
          body plugin.output
        end
      end
    
      HYDRA.queue request
      HYDRA.run
    end
   
    get /^\/(.+)/ do |proxy_token|
      authenticate_user!
      
      decrypted = RProxy.user_model.decrypt_url(proxy_token)
      url = URI.parse((decrypted[:url])? decrypted[:url] : decrypted[:plugin].url)
      app_path = URI.parse(request.url)

      plugin = decrypted[:plugin]
      user = decrypted[:user]
    
      options = TYPHOEUS_OPTIONS.merge(:method => :get)
      options.merge!({:headers => plugin.headers(user)}) if plugin.respond_to?(:headers)
   
      request = Typhoeus::Request.new(url.to_s, options)
      request.on_complete do |response|
        content_type = response.headers_hash['Content-Type']
        encoding = (content_type.blank?) ? nil : content_type.split(";").last.split("=").last
        plugin.process response.body, user, url, app_path, plugin, encoding
        body plugin.output
      end
    
      HYDRA.queue request
      HYDRA.run
    end
    
  end
  
end