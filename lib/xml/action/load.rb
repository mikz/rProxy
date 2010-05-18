class XMLProcessor::Action::Load < XMLProcessor::Action
  def initialize node, document, &block
    super(node, document, block.binding)
    
    variable = node.attribute("from").value
    
    @element = self[variable]
    
    block[self]

    self
  end
end