class RProxy::Plugin
  module Worker
    
    def self.included(base)
      DEBUG {%w{base}}
    end
    attr_accessor :request, :response, :plugin
    attr_reader :document
    INVALID_LINKS = ["http://","https://","javascript:","mailto:","#"]
    INVALID_LINK = /^(((http|https)\:\/\/)|((javascript|mailto)\:)|\#)/i
    PARSER_OPTIONS = Nokogiri::XML::ParseOptions::DEFAULT_XML | Nokogiri::XML::ParseOptions::STRICT
    SERIALIZE_OPTIONS = Nokogiri::XML::Node::SaveOptions::AS_XHTML
    FORMATS = [:xhtml, :html]
    DEFAULT_FORMAT = FORMATS.first

    
    def process thing, user, base_url, app_path, plugin = self
      case format
        when :html
          @document = Nokogiri::HTML(thing)
        when :xhtml, :xml
          @document = Nokogiri::XML(thing)
        else
          @document = Nokogiri::XML(thing)
      end
      @user = user
      @url = base_url
      @app_path = app_path
      @plugin = plugin

      add_base_tag
      replace_links

    end


    def output
      return nil unless @document
      @document.serialize
    end

    private
    def format
      nil || @format
    end
    def add_base_tag
      begin
      base = Nokogiri::XML::Node.new "base", @document
      base["href"] = @url.to_s
      @document.xpath("//xmlns:head", "xmlns" => @document.namespaces['xmlns']).children.first.add_previous_sibling base
      rescue
      end
    end
    def replace_links
      @document.xpath('//xmlns:a[@href] | //xmlns:form[@action]', "xmlns" => @document.namespaces['xmlns']).each do |node|
        case node.name
          when "a"
            node['href'] = @app_path.merge("/p/" + @user.encrypt_url(@plugin.id, @url.merge(node['href']))).to_s unless node['href'] =~ INVALID_LINK
          when "form"
            node['action'] = @app_path.merge("/p/" + @user.encrypt_url(@plugin.id, @url.merge(node['action']), node['method'] || "GET")).to_s
        end
      end
    end
  end
end