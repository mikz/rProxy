class XMLProcessor::Action::Create < XMLProcessor::Action
  def initialize node, document, &block
    super(node, document, block.binding)
#    format = @document.instance_variable_get "@format"
    case node.attribute("from").value.to_sym
    when :CDATA
        
#      nodeset = Nokogiri::XML.fragment(node.text).children
      nodeset = Nokogiri::XML::DocumentFragment.new(document, replace_tokens(node.text)).children
    else
      raise XMLProcessor::NotImplementedError.new(node.attribute("from").value)
    end
    
    type = node.attribute("type")
    @element = element_from(nodeset, (type)? type.value : nil)
    
    block[self]

    self
  end
  
  def replace_tokens text
    DEBUG {%w{plugin}}
    text.gsub(/\#\{(.*?)\}/) {
      plugin.get_token($1)
    }
  end
  
end