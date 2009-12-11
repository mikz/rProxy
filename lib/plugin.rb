module RProxy
  class Plugin
    include Nokogiri
    attr_accessor :request, :response
    attr_reader :document
    INVALID_LINKS = ["http://","https://","javascript:","mailto:","#"]
    INVALID_LINK = /^(((http|https)\:\/\/)|((javascript|mailto)\:)|\#)/i
    PARSER_OPTIONS = XML::ParseOptions::NOERROR | XML::ParseOptions::RECOVER | XML::ParseOptions::NOWARNING
    SERIALIZE_OPTIONS = nil
    
    def initialize thing
      @document = Nokogiri::HTML::Document.parse(thing, nil, "UTF-8", PARSER_OPTIONS)
      #STDERR << %{
      #  #{@document.inspect} # SEGFAULTS!!!!!!
      #}
      add_base_tag
      replace_links
    end
    
    
    def to_s
      return nil unless @document
      @document.serialize(:encoding => 'UTF-8', :save_with => SERIALIZE_OPTIONS )
    end
    
    private
    def add_base_tag
      base = XML::Node.new "base", @document
      base["href"] = 'http://idos.dpp.cz/idos/'
      @document.xpath("//head[1]").first.add_previous_sibling base
    end
    def replace_links
      @document.xpath('//a[@href] | //form[@action]').each do |node|
        case node.name
          when "a"
            node['href'] = "TEST HREF" unless node['href'] =~ INVALID_LINK
          when "form"
            node['action'] = "TEST ACTION"
        end
      end
    end
  end
end