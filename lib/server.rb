require 'sinatra/async'
require 'typhoeus'
require 'uri'

require 'sinatra_more'
SinatraMore::WardenPlugin::PasswordStrategy.user_class = User




module RProxy
  class Server < Sinatra::Base
    register Sinatra::Async
    register SinatraMore::WardenPlugin
    
    enable :show_exceptions
    enable :sessions
    set :haml, {:format => :xhtml}
    
    HYDRA = Typhoeus::Hydra.new
    
    get '/login/?' do
      haml :login
    end
    
    post '/login/?' do
      authenticate_user!
      redirect "/test"
    end

    post '/unauthenticated/?' do
      @notice = "That username and password are not correct!"
      status 401
      haml :login
    end
    
    get '/logout/?' do
      logout_user!
      redirect '/login'
    end
    
    
    get "/test" do
      must_be_authorized! "/login"
      current_user.inspect
    end
    
    get "/p" do
      must_be_authorized! "/login"
      @plugins = Plugin.all
      @current_user = current_user
      haml :proxies
    end
    
    apost '/p/:proxy_token' do
      decrypted = User.decrypt_url(params.delete("proxy_token"))
      
      url = URI.parse((decrypted[:url])? decrypted[:url] : decrypted[:plugin].url)
      app_path = URI.parse(request.url)

      request = Typhoeus::Request.new(url.to_s, :method => :post, :params => params, :follow_location => true)
      request.on_complete do |response|
        
        headers = response.headers.split("\r\n")
        headers.each do |header|
          if header =~ /Location\:\ (.+)$/i
            url = url.merge($1)
            
            @redirect = redirect("/p/" + current_user.encrypt_url(decrypted[:plugin].id, url))
          end
          
        end if headers[2] =~ /302\ Found$/
        
        if !@redirect
          plugin = decrypted[:plugin].worker response.body, current_user, url, app_path
          body plugin.to_s
        end
      end
      
      HYDRA.queue request
      HYDRA.run
    end
    
    aget '/p/:proxy_token' do
      decrypted = User.decrypt_url(params.delete("proxy_token"))
      url = URI.parse((decrypted[:url])? decrypted[:url] : decrypted[:plugin].url)
      app_path = URI.parse(request.url)

      request = Typhoeus::Request.new(url.to_s, :method => :get, :follow_location => true)
      request.on_complete do |response|

        plugin = decrypted[:plugin].worker response.body, current_user, url, app_path
        body plugin.to_s
      end
      
      HYDRA.queue request
      HYDRA.run
    end
  end
end

Warden::Manager.serialize_from_session { |id|  id.nil? ? nil : SinatraMore::WardenPlugin::PasswordStrategy.user_class[id] }