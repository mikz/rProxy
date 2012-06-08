module RProxy
  class XMLProcessor::Action::Load < XMLProcessor::Action
    def initialize processor, node, &init
    
      variable = node.attribute("from").value

      super(processor, node) {
        self.element = self[variable]
        self.element.document = document if self.element
      }

      self
    end
  end
end