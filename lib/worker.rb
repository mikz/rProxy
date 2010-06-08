require "lib/xml/processor"

class RProxy::Plugin
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
      DEBUG {%w{format thing.encoding}}
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
      
      add_base_tag
      replace_links
      
      process_xml if self.respond_to?(:xml)
    end


    def output
      return nil unless @document
      output = @document.serialize
      DEBUG {%w{@encoding output.encoding @document.meta_encoding}}
      output.force_encoding(@encoding) unless @encoding.nil?
    end



    private
    
    def process_xml xml = self.xml, rng_schema = self.rng_schema
      processor = XMLProcessor.new( xml, rng_schema) do |processor|
        processor.process! @document
      end
    end

    def format
      nil || @format || (self.class.const_defined?(:FORMAT)) ? self.class.const_get(:FORMAT) : nil
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
      case format
        when :html
          selector = ['//a[@href] | //form[@action]']
        when :xhtml, :xml, nil
          selector = ['//xmlns:a[@href] | //xmlns:form[@action]', "xmlns" => @document.namespaces['xmlns']]
      end
      DEBUG {%w{selector}}
      @document.xpath(*selector).each do |node|
        case node.name
          when "a"
            node['href'] = @app_path.merge("/p/" + @user.encrypt_url(self.id, @url.merge(node['href']))).to_s unless node['href'] =~ INVALID_LINK
          when "form"
            node['action'] = @app_path.merge("/p/" + @user.encrypt_url(self.id, @url.merge(node['action']), node['method'] || "GET")).to_s
        end
      end
    end
  end
end