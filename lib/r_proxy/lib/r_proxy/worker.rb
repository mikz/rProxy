module RProxy
  module Worker
    
    attr_accessor :request, :response
    attr_reader :document, :user
    
    INVALID_LINKS = ["http://","https://","javascript:","mailto:","#"]
    INVALID_LINK = /^(((http|https)\:\/\/)|((javascript|mailto)\:)|\#)/i
    PARSER_OPTIONS = Nokogiri::XML::ParseOptions::DEFAULT_XML | Nokogiri::XML::ParseOptions::STRICT
    SERIALIZE_OPTIONS = Nokogiri::XML::Node::SaveOptions::AS_XHTML
    FORMATS = [:xhtml, :html]
    DEFAULT_FORMAT = FORMATS.first

  
    def process thing, user, base_url, app_path, plugin = self, encoding = nil
      thing.force_encoding encoding if encoding
      @encoding = encoding
      
      case format
        when :html
          @document = Nokogiri::HTML(thing, nil, encoding)
        when :xhtml, :xml
          @document = Nokogiri::XML(thing)
        else
          @document = Nokogiri::XML(thing)
      end
      
      @user = user
      @url = base_url
      @app_path = app_path
    
      @output = {
        :method => :serialize,
        :variable => "@document"
      }
    
      
      begin
        add_base_tag
        replace_links
        process_xml if self.respond_to?(:xml)
      rescue Nokogiri::XML::SyntaxError => e
        @error = e
        @output = {:method => :inspect, :variable => "@error"}
      end
    end
  
    def output_method= val
      @output[:method] = val.to_sym
    end
  
    def output_variable= val
      @output[:variable] = val
    end
    
    def output_variable
      self.instance_variable_get(@output[:variable])
    end
    
    def output
      case @output[:method]
      when :serialize
        document = output_variable
        output = document.serialize :encoding => encoding
        output.force_encoding(encoding) if encoding.present?
        output
      when :plain
        output_variable
      when :inspect
        output_variable.inspect
      end
    end
    
  
    def path(query, user = nil)
      unless user
        "/p/?" + query
      else
        path user.encrypt_url(self.id, query)
      end
    end
    
    private
  
    def process_xml xml = self.xml, rng_schema = self.rng_schema
      processor = XMLProcessor.new(self, xml, rng_schema)
      processor.process! @document
    end

    def format
      nil || @format || (self.class.const_defined?(:FORMAT)) ? self.class.const_get(:FORMAT) : nil
    end
    
    def encoding
      @encoding.presence || (output_variable.respond_to?(:meta_encoding) ? output_variable.meta_encoding : nil)
    end
    
    def add_base_tag
      begin
      base = Nokogiri::XML::Node.new "base", @document
      base["href"] = @url.to_s
      case format
        when :html
          selector = ["//head"]
        when :xhtml, :xml, nil
          selector = ["//xmlns:head", "xmlns" => @document.namespaces['xmlns']]
      end
      @document.xpath(*selector).children.first.add_previous_sibling base
      rescue
      end
    end
  
    def replace_links
      if format == :html || (!format &&  @document.namespaces.blank?)
        selector = ['//a[@href] | //form[@action]']
      elsif [:xml, :xhtml].include?(format) || (!format && @document.namespaces.present?)
        selector = ['//xmlns:a[@href] | //xmlns:form[@action]', "xmlns" => @document.namespaces['xmlns']]
      end
      @document.xpath(*selector).each do |node|
        case node.name
          when "a"
            node['href'] = @app_path.merge(path @user.encrypt_url(self.id, @url.merge(node['href']))).to_s unless node['href'] =~ INVALID_LINK
          when "form"
            node['action'] = @app_path.merge(path @user.encrypt_url(self.id, @url.merge(node['action']), node['method'] || "GET")).to_s
        end
      end
    end
  end
end