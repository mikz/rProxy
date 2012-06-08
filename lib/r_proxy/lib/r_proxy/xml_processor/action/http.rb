module RProxy
  class XMLProcessor::Action::Http < XMLProcessor::Action
    attr_reader :state

    def initialize proccessor, node, init = nil
    
      super
    
      method = node.attribute("method").value
      url = node.attribute("url").value
      params = {}
      key = nil
      node.search("./xmlns:data/*", node.namespaces).each do |elem|
        case elem.name.to_sym
        when :param
          params[elem.attribute("name").value] = elem.text
        when :key
          key = elem.text
        when :value
          params[key] = elem.text
        else
          raise XMLProcessor::NotImplementedError.new(param.name.to_sym)
        end
      end
      cache = @node.xpath("./cache")
      cache = cache.empty? ? nil : cache.attribute("timeout")
    
      fixes = {}
      @node.xpath('./xmlns:fixes/*').each do |fix|
        fixes[fix.name.to_sym] = true
      end
    
      nodes = @node.xpath('./*')
      control = @node.xpath('./xmlns:data |./xmlns:cache | ./xmlns:fixes', @node.namespaces)
      @nodes = nodes - control
    
      @state = :loading
    
      @loader = Loader.new url.to_s, :method => method, :params => params, :fixes => fixes
    
      self
    end
    def process!
      Fiber.new {
        
      }.resume
      xmlprocessor = self.send(:processor)
      processor = lambda { |l|
        xmlprocessor.process! l.document, @nodes do
          process_block!
        end
      }
      @loader.callback = processor
    end
    class Loader
      attr_accessor :callback, :state
      attr_reader :document
      def callback= callback
        if @state == :ready
          callback[self]
        else
          @callback = callback
        end
        callback
      end
      def ready!
        self.state = :ready
      end
      def state= state
        if state == :ready
          callback[self] if callback
        end
        @state = state
      end
      def initialize url, options = {}
        @fixes = options.delete(:fixes)
        create_request(url, options)
        self
      end
      def create_request url, options = {}
        request = Typhoeus::Request.new(url.to_s, options)
        callback = Proc.new { |response|
          case response.code
            when 200
              document = response.body
              @fixes.each_pair do |key, val|
                fix(document, key) if val
              end
              @document = self.class.parse_document(document)
              self.ready!
            when 302
              headers = response.headers_hash
              location = headers["location"]
              cookies = headers["Set-Cookie"].collect{|line|line.split(";").first}
              url  = URI.parse(request.url).merge(location)
              create_request url, {:headers => {:Cookie => cookies.join("; ")}}.merge(options)
          end
        }
        request.on_complete &callback
        HYDRA.queue request
        HYDRA.run
      end
      def fix document, how
        case how
        when :amp
          document.gsub! /(&)(?!amp;)/, "&amp;"
        end
      end
      def self.parse_document document
        begin
          Nokogiri::XML(document)
        rescue
          Nokogiri::HTML(document)
        end
      end
    end
  end
end