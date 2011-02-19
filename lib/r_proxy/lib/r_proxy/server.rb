module RProxy
  class Server < ::Sinatra::Base
    #register ::Sinatra::Async
    
    
    enable :show_exceptions
    
    
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
      
      def warden
        request.env['warden']
      end
      
      def authenticate_user!(force = false)
#        catch(:warden) do
          warden.authenticate!(:scope => :user) || force
#        end
      end
      
      def current_user
        @current_user ||= warden.authenticate(:scope => :user)
      end
      
      def query
        request.env['QUERY_STRING']
      end
      
      def content_type(plugin)
        if plugin.respond_to? :content_type
          response['Content-Type'] = plugin.content_type
        end
      end

    end
    
    post '/' do
      authenticate_user!
      req = Request.post(query)
      resp = req.process request.url, params
      

      if req.redirected?
        redirect req.location
      else
        content_type(req.plugin)
        body resp
      end
    end
   
    get '/' do
      #authenticate_user!

      req = Request.get(query)
      resp = req.process request.url, params
            
      if req.redirected?
        redirect req.location
      else
        content_type(req.plugin)
        body resp
      end
    end
  end
  
end