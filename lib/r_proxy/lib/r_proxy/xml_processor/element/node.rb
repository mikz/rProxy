module RProxy
  module XMLProcessor::Element
    class Node
      attr_reader :node
      attr_accessor :document

      def initialize node
        case node
        when Nokogiri::XML::Element, Nokogiri::XML::Node
          @node = node
        when Nokogiri::XML::NodeSet
          @node = node.first
        end
      end
  
      def length
        @node ? 1 : 0
      end
  
      def parent method, action
        action.element = @node.parent

        process_children method, action
      end

      def back method, action
        element = action.back!

        process_children method, action
      end

      def next method, action
        action.element = @node.next

        process_children method, action
      end

      def prev method, action
        action.element = @node.previous

        process_children method, action
      end

      def clone method, action
        original = @node
        element = @node.dup(clone_method(method))
        element.namespace = original.namespace
        action.element = element
      end
  
      def log method, action
        DEBUG {method.attribute("vars").value.split(" ")}
      end

      def modify method, action
        method.attributes.each_pair do |name, attr|
          case name.to_sym #modify's attributes
          when :attribute
            @node.attribute(attr.value).value = self.class.value_from(action)
          end
        end
      end

      def insert method, action
        doc = @node.document
        method.xpath("*").each do |node|
          selectors = node.attributes.map{|name,attr| attr.value }
          elem = doc.search(*selectors, doc.namespaces).first
          case node.name.to_sym
          when :before
            elem.add_previous_sibling(@node)
          when :after
            elem.add_next_sibling(@node)
          when :into
            case node.attribute("location").value.to_sym
            when :top
              elem.children.first.add_previous_sibling(@node)
            when :bottom
              elem.children.last.add_next_sibling(@node)
            else
              raise NotImplementedError.new(node.attribute("location"))
            end
          else
            raise NotImplementedError.new(node.name)
          end
        end
      end

      def remove method, action
        attr = method.attribute("attribute")
        if(attr)
          @node.remove_attribute(attr.value)
        else
          @node.remove
        end
      end

      def save method, action
        method.attributes.each_pair do |name, attr|
          case name.to_sym
          when :to
            action[attr.value] = self
          end
        end
      end
  
      def call method, action
        plugin = action.plugin
    
        if(attr = method.attributes["method"])
          return plugin.send(attr.value.to_sym, self)
        end
    
        if(ruby = Ruby.new(method.text))
          plugin.instance_eval(ruby) if ruby.valid?
        end
      end

      def self.value_from node
        value = node.attribute(:value)
        (value)? value.value : node.text
      end
  
      protected
  
      def clone_method method
        attr = method.attribute("method")
        val = (attr)? attr.value : CLONE_DEFAULT
        CLONE_METHODS[val.to_sym]
      end
  
      def process_children method, action
        children = method.xpath("*")
        return if children.empty?
        children.each do |child|
          action.element.send child.name.to_sym, child, action
        end
        action.back!
      end
    end
  end
end