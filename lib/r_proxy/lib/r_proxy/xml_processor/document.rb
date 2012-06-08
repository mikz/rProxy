module RProxy
  class XMLProcessor
    
    class Document < Struct.new(:document, :processor)
      delegate :plugin, :to => :processor
      delegate :vars, :to => :processor
    end
  end
end