module RProxy
  class XMLProcessor
    autoload :Element, "r_proxy/xml_processor/element"
    autoload :Action, "r_proxy/xml_processor/action"
    autoload :Document, "r_proxy/xml_processor/document"
    
    attr_reader :plugin, :document, :vars, :xml, :schema
    delegate :[]=, :[], :to => :vars
    
    class InvalidXML < Exception
      def initialize; %{XML file is invalid according to its schema.}; end
    end
  
    class NotImplementedError < Exception
      def initialize(what); %{#{what} is not implemented}; end
    end
  
    def initialize plugin, xml, schema = nil
      @plugin = plugin
      @vars = ActiveSupport::HashWithIndifferentAccess.new
      parse_xml xml, schema
      
      yield if block_given?
      
      return self
    end
    
    def process! document, nodes = nil, &callback
      @document = document = Document.new(document, self)
      actions = []
    
      @xml.root.attributes.each_pair do |name, attr|
        next unless attr.namespace.prefix.to_sym == :output
        case name.to_sym
        when :method
          plugin.output_method = attr.value
        when :variable
          plugin.output_variable = attr.value
        end
      end
      nodes ||= @xml.root.xpath("*")
      nodes.each do |node|
        actions << Action.new_for(self, node).process!
      end
      
      actions
    end
    
    def []= var, val
      @vars[var.to_sym] = val
    end
  
    def [] var
      @vars[var.to_sym]
    end
    
    def parse_xml(xml, schema = nil)
      @xml = Nokogiri::XML(xml)
      if schema.present?
        @schema = Nokogiri::XML::RelaxNG(schema) 
        #check_xml!
      end
    end
    
    def check_xml!
      self.class.check_xml! @xml, @schema
    end
    
    def self.check_xml! xml, schema
      schema.validate(xml).each do |error|
        raise error
      end
    end
  
  end
end