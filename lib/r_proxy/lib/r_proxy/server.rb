module RProxy
  class Server < ::Sinatra::Base
    register ::Sinatra::Async
    
    enable :show_exceptions
    
    
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

    end
    
    def native_async_schedule(&b)
  
      #EM.next_tick(&b)
      EM.next_tick(Proc.new { Fiber.new { b.call }.resume })
    end
    
    aget '/delay/:n' do |n|
      EM.add_timer(n.to_i) { body { "delayed for #{n} seconds" } }
    end
    
    apost '/' do
      authenticate_user!
      req = Request.post(query)
      response = req.process request.url, params
      
      if req.redirected?
        DEBUG {%w{req.location}}
        aredirect req.location
      else
        body response
      end
    end
   
    aget '/' do
      #authenticate_user!

      req = Request.get(query)
      response = req.process request.url, params
      
      if req.redirected?
        DEBUG {%w{req.location}}
        aredirect req.location
      else
        body response
      end
    end
  end
  
end