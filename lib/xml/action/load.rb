class XMLProcessor::Action::Load < XMLProcessor::Action
  def initialize node, document, &block
    
    variable = node.attribute("from").value
    init = Proc.new {
      @element = self[variable]
      @element.document = document
    }
    super node, document, init, &block

    self
  end
end