require "active_support/inflector"

class XMLProcessor
  class InvalidXML < Exception
    def initialize; %{XML file is invalid according to its schema.}; end
  end
  class NotImplementedError < Exception
    def initialize(what); %{#{what} is not implemented}; end
  end
  
  def initialize xml, schema = nil, &block
    valid = check_xml! xml, schema
    
    raise InvalidXML.new unless valid
    
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
    nodes ||= @xml.root.xpath("*")
    nodes.each do |action|
      actions << Action.new_for(action, document) do |a|
        a.process_callback!
      end
    end
    last = nil
    actions.reverse.each do |a|
      DEBUG {%w{a.class last.class}}
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

    errors = @schema.validate(@xml).each do |error|
      DEBUG {%w{error}}
    end
    errors.empty?
  end
  

  
  class Action
    PREFIX = "XMLProcessor::Action::"
    attr_writer :callback
    
    def initialize node, document, init = nil, &block
      @document = document
      @node = node
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
        @element.send node.name, node, self
      end if @element
    end
    def process_callback!
      if @callback
        callback = @callback
        @callback = callback
        callback.process!
      end
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
        XMLProcessor::Element::Node.new nodeset.first
      end
    end
    
    class << self
      def find_class_for element
        name = PREFIX + ActiveSupport::Inflector.camelize(element.name)
        ActiveSupport::Inflector.constantize name
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
  class Element
    CLONE_METHODS = {:shallow => 0, :deep => 1}
    CLONE_DEFAULT = :deep
    class Node
      attr_reader :node
      attr_accessor :document
    
      def initialize node
        @node = node
      end
      
    
      def clone method, action
        original = @node
        @node = @node.dup(clone_method(method))
        @node.namespace = original.namespace
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
        DEBUG {%w{method @node}}
        method.xpath("*").each do |node|
          selectors = node.attributes.map{|name,attr| attr.value }
          elem = doc.search(*selectors, doc.namespaces).first
          DEBUG {%w{selectors doc.namespaces elem}}
          case node.name.to_sym
          when :before
            elem.add_previous_sibling(@node)
          when :after
            elem.add_next_sibling(@node)
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
    end
    class Set < Node
      def initialize node
        @node = @nodeset = node
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
                DEBUG {%w{node eq elem }}
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
        @nodeset = nodeset
      end
    end
  end
end

Dir["lib/xml/action/*.rb"].each do |action|
  require action
end