module RProxy
  class XMLProcessor::Action::Find < XMLProcessor::Action
    SELECTORS = %w{xpath css}
    def initialize processor, node, &init
      selectors = node.attributes.select { |name, attr| SELECTORS.include?(name)}.map{|name,attr| attr.value }
      super(processor, node) {
        nodeset = document.search *selectors, document.namespaces
        self.element = element_from(nodeset)
      }
      self
    end

  end
end