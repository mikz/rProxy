module RProxy
  class XMLProcessor
    class Action
      autoload :Create, "r_proxy/xml_processor/action/create"
      autoload :Find, "r_proxy/xml_processor/action/find"
      autoload :Http, "r_proxy/xml_processor/action/http"
      autoload :Load, "r_proxy/xml_processor/action/load"
      autoload :Return, "r_proxy/xml_processor/action/return"
      
      attr_reader :processor, :node
      delegate :plugin, :to => :processor
      delegate :[]=, :[], :to => :processor
      delegate :document, :to => :processor, :prefix => true
      delegate :document, :to => :processor_document
  
      def initialize xml_processor, node, &init
        @processor = xml_processor
        @node = node
        @stack = []
        @init = init

        self
      end
    
      def process!
        process_init!
        process_nodes!
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
        @stack.length > 0 && element.length > 0 if element.present?
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
          Element::Set.new nodeset
        when :node
          Element::Node.new nodeset
        end
      end
  
      class << self
        def find_class_for node
          name = self.to_s + "::" + node.name.camelize
          name.constantize
        end

        def new_for processor, node
          find_class_for(node).new(processor, node)
        end
      end
    
    end
  end
end