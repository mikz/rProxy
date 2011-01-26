module RProxy
  class XMLProcessor
    autoload :Element, "r_proxy/xml_processor/element"
    autoload :Action, "r_proxy/xml_processor/action"
    
    class InvalidXML < Exception
      def initialize; %{XML file is invalid according to its schema.}; end
    end
  
    class NotImplementedError < Exception
      def initialize(what); %{#{what} is not implemented}; end
    end
  
    def initialize xml, schema = nil, &block
      check_xml! xml, schema
    
      @vars = {}
      @binding = block.binding
      yield self
      return self
    end
  
    def plugin
      @plugin ||= eval "self", @binding
    end

  
    def process! document, nodes = nil, &callback
      @document ||= document
      actions = []
    
      plugin = self.plugin
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
      nodes.each do |action|
        actions << Action.new_for(action, document) do |a|
          a.process_callback!
        end
      end
      last = nil
      actions.reverse.each do |a|
        a.callback = last if last
        last = a
      end
      actions.first.process!
      callback[self] if callback
    end
    
    def []= var, val
      @vars[var.to_sym] = val
    end
  
    def [] var
      @vars[var.to_sym]
    end
  
    def check_xml! xml, schema
      @xml = Nokogiri::XML(xml)

      return @xml unless schema
      @schema = Nokogiri::XML::RelaxNG(schema)

      @schema.validate(@xml).each do |error|
        raise error
      end
    end
  
  end
end