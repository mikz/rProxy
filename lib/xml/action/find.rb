class XMLProcessor::Action::Find < XMLProcessor::Action
  SELECTORS = %w{xpath css}
  def initialize node, document, &block
    selectors = node.attributes.select { |name, attr| SELECTORS.include?(name)}.map{|name,attr| attr.value }
    
    STDERR << document.to_s if selectors.join("") == "div.routes > div a:first-child"
    init = Proc.new {
      nodeset = document.search *selectors, document.namespaces
      @element = element_from(nodeset)
      DEBUG {%w{selectors}}
    }
    super node, document, init, &block
    
    self
  end

end