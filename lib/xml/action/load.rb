class XMLProcessor::Action::Load < XMLProcessor::Action
  def initialize node, document, &block
    
    variable = node.attribute("from").value
    init = Proc.new {
      self.element = self[variable]
      self.element.document = document
    }
    super node, document, init, &block

    self
  end
end