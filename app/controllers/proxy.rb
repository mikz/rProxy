module RProxy
  class Server
    aget "/p" do
      must_be_authorized! "/login"
      @plugins = Plugin.all
      @current_user = current_user
      body haml(:proxies)
    end
  
    apost /^\/p\/(.+)/ do |proxy_token| 
      must_be_authorized! "/login"
      decrypted = User.decrypt_url(proxy_token)
    
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
   
    aget /^\/p\/(.+)/ do |proxy_token|
      #must_be_authorized! "/login"
      decrypted = User.decrypt_url(proxy_token)
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