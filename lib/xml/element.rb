class XMLProcessor
  module Element
    CLONE_METHODS = {:shallow => 0, :deep => 1}
    CLONE_DEFAULT = :deep
  end
end

require "lib/xml/element/node"
require "lib/xml/element/set"