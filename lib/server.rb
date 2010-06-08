require 'sinatra/async'
require 'typhoeus'
require 'uri'

require 'rack-flash'

require "lib/helpers"

require "haml"
require 'sinatra_more'
SinatraMore::WardenPlugin::PasswordStrategy.user_class = User

module RProxy
  class Server < Sinatra::Base
    register Sinatra::Async
    register SinatraMore::WardenPlugin
    
    
    use Rack::Flash
    
    helpers Sinatra::Partials
    include SinatraHelpers
    
    enable :show_exceptions
    enable :sessions
    set :haml, {:format => :xhtml, :encoding => 'UTF-8'}
    set :public, 'public'
    
    TYPHOEUS_OPTIONS = {
      :follow_location => true,
      :max_redirects => 5,
#      :timeout => 60*100, # 60 seconds
      :cache_timeout => 15*60 # 15 minutes
      
    }
    HYDRA_OPTIONS = {
      :max_concurency => 50
    }
    
    HYDRA = init_hydra HYDRA_OPTIONS
    
    get '/login/?' do
      haml :login
    end
    
    post '/login/?' do
      authenticate_user!
      redirect "/p"
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
    
    get "/user_data" do
      must_be_authorized! "/login"
      @user_data = current_user.user_data
      haml :user_data
    end
    
    get "/user/:controller/?" do
      controller = params[:controller].downcase.to_sym
      pass unless [:configs, :data].include?(controller)
      must_be_authorized! "/login"
      instance_variable_set "@#{controller}".to_sym, current_user.send(controller)
      haml controller
    end
    get "/user/:controller/:id/edit/?" do
      controller = params[:controller].downcase.to_sym
      pass unless [:config, :data].include?(controller)
      must_be_authorized! "/login"
      
      @plugins = Plugin.all
      instance_variable_set(
        "@#{controller}".to_sym,
        "User::#{controller.to_s.capitalize}".constantize.get(*params[:id].split(",")))
      haml "#{controller}/edit".to_sym
    end
    
    post "/user/:controller/:id/update/?" do
      controller = params[:controller].downcase.to_sym
      pass unless [:config, :data].include?(controller)
      must_be_authorized! "/login"
      
      @plugins = Plugin.all
      var = "User::#{controller.to_s.capitalize}".constantize.get *params[:id].split(",")
      instance_variable_set "@#{controller}".to_sym, var
      if var.update(params[controller])
        flash[:notice] = "Successfully saved"
        redirect "/user/#{controller.to_s.pluralize}"
      else
        haml "#{controller}/edit".to_sym
      end
    end
    
    get "/user/:controller/:id/destroy/?" do
      controller = params[:controller].downcase.to_sym
      pass unless [:config, :data].include?(controller)
      must_be_authorized! "/login"
      
      @plugins = Plugin.all
      var = "User::#{controller.to_s.capitalize}".constantize.get *params[:id].split(",")
      var.destroy
      redirect "/user/#{controller.to_s.pluralize}"
    end
    
    get "/user/:controller/new/?" do
      controller = params[:controller].downcase.to_sym
      pass unless [:config, :data].include?(controller)
      must_be_authorized! "/login"
      
      @plugins = Plugin.all
      instance_variable_set "@#{controller}".to_sym, "User::#{controller.to_s.capitalize}".constantize.new
      haml "#{controller}/new".to_sym
    end
    
    post "/user/:controller/create/?" do
      controller = params[:controller].downcase.to_sym
      pass unless [:config, :data].include?(controller)
      must_be_authorized! "/login"
      
      @plugins = Plugin.all
      var = "User::#{controller.to_s.capitalize}".constantize.new params[controller]
      var.user = current_user
      instance_variable_set "@#{controller}".to_sym, var
      if var.save
        flash[:notice] = "Successfully saved"
        redirect "/user/#{controller.to_s.pluralize}"
      else
        
          DEBUG {%w{var.errors}}
        haml "#{controller}/new".to_sym
      end
    end
  
    get "/p" do
      must_be_authorized! "/login"
      @plugins = RProxy::Plugin.all
      @current_user = current_user
      haml :proxies
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
      must_be_authorized! "/login"
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

HYDRA = RProxy::Server::HYDRA

Warden::Manager.serialize_from_session { |id|  id.nil? ? nil : SinatraMore::WardenPlugin::PasswordStrategy.user_class[id] }