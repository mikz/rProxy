module RProxy
  class XMLProcessor
    class Action
      autoload :Create, "r_proxy/xml_processor/action/create"
      autoload :Find, "r_proxy/xml_processor/action/find"
      autoload :Http, "r_proxy/xml_processor/action/http"
      autoload :Load, "r_proxy/xml_processor/action/load"
      autoload :Return, "r_proxy/xml_processor/action/return"
      
      attr_writer :callback
  
      def initialize node, document, init = nil, &block
        @document = document
        @node = node
        @stack = []
        @block = block
        @init = init
        @binding = block.binding
        self
      end
  
      def []= var, val
        processor[var] = val
      end
    
      def [] var
        processor[var]
      end
  
      def plugin
        @plugin ||= eval  "plugin", @binding
      end
  
      def process_block!
        if @block
          block = @block
          @block = nil
          block[self]
        end
      end
    
      def process!
        process_init!
        process_nodes!
        process_block!
      end
    
      def process_init!
        if @init
          init = @init
          @init = nil
          init[self]
        end
      end
    
      def process_nodes!
        @node.xpath("*").each do |node|
          element.send node.name, node, self
        end if element?
      end
    
      def process_callback!
        if @callback
          callback = @callback
          @callback = callback
          callback.process!
        end
      end
    
      def element
        @stack.last
      end
  
      def element= element
        case element
        when Nokogiri::XML::Element, Nokogiri::XML::Node, Nokogiri::XML::NodeSet
          element = element_from(element)
        end
        @stack.push element
      end
  
      def element?
        @stack.length > 0 && element.length > 0
      end
    
      def back!
        @stack.pop
      end
  
      def element_from nodeset, type = nil
        return nil if nodeset.nil?
        case nodeset
        when Nokogiri::XML::Element, Nokogiri::XML::Node
          type = :node
        when Nokogiri::XML::NodeSet
          type = (type)? type.to_sym : ((nodeset.length > 1)? :set : :node)
        end
        case type
        when :set
          XMLProcessor::Element::Set.new nodeset
        when :node
          XMLProcessor::Element::Node.new nodeset
        end
      end
  
      class << self
        def find_class_for element
          name = self.to_s + "::" + element.name.camelize
          name.constantize
        end

        def new_for element, document, &block
          find_class_for(element).new(element, document, &block)
        end
      end
    
      private
    
      def processor
        @processor ||= (eval "self", @binding)
      end
    
    end
  end
end