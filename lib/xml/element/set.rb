class XMLProcessor
  module Element
    class Set < Node
      def initialize node
        @node = @nodeset = node
      end
      
      def length
        @nodeset.length
      end
      
      def insert method, action
        doc = self.document || @node.document
        method.xpath("*").each do |node|
          selectors = node.attributes.map{|name,attr| attr.value }
          elem = doc.search(*selectors, doc.namespaces).first
          case node.name.to_sym
          when :before
            @nodeset.each do |node|
          
              elem.add_previous_sibling(node)
            end
          when :after
            @nodeset.reverse.each do |node|
                eq = node.document == elem.document
              elem.add_next_sibling(node)
            end
          else
            raise NotImplementedError.new(node.name)
          end
        end
      end
    
      def clone method, action
        nodeset = Nokogiri::XML::NodeSet.new @nodeset.document
        @nodeset.each do |node|
          nodeset << node.clone(clone_method(method))
          nodeset.last.namespace = node.namespace
        end
        action.element = nodeset
      end
    end
  end
end