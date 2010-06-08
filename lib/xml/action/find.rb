class XMLProcessor::Action::Find < XMLProcessor::Action
  SELECTORS = %w{xpath css}
  def initialize node, document, &block
    selectors = node.attributes.select { |name, attr| SELECTORS.include?(name)}.map{|name,attr| attr.value }
    DEBUG {%w{selectors}}
    init = Proc.new {
      nodeset = document.search *selectors, document.namespaces
      self.element = element_from(nodeset)
    }
    super node, document, init, &block
    
    self
  end

end