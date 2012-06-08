module RProxy
  class XMLProcessor::Action::Return < XMLProcessor::Action
    attr_accessor :output
  
    def initialize node, document, &block
    
      variable = node.attribute("variable").value
      init = Proc.new {
        self.output = self[variable]
      }
      super node, document, init, &block

      self
    end
  end
end