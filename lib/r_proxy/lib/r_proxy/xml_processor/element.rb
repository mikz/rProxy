module RProxy
  class XMLProcessor
    module Element
      autoload :Node, "r_proxy/xml_processor/element/node"
      autoload :Set, "r_proxy/xml_processor/element/set"
      
      CLONE_METHODS = {:shallow => 0, :deep => 1}
      CLONE_DEFAULT = :deep
    end
  end
end
