class XMLProcessor::Action::Find < XMLProcessor::Action
  SELECTORS = %w{xpath css}
  def initialize node, document, &block
    super(node, document, block.binding)
    
    selectors = node.attributes.select { |name, attr| SELECTORS.include?(name)}.map{|name,attr| attr.value }
    nodeset = document.search *selectors, document.namespaces
    
    @element = element_from(nodeset)
    
    block[self]

    self
  end

end