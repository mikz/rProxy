module RProxy
  class XMLProcessor::Action::Create < XMLProcessor::Action
    def initialize processor, node, &init
  #    format = @document.instance_variable_get "@format"
      nodeset = nil
      type = node.attribute("type")
      
      super(processor, node){
        self.element = element_from(nodeset, (type)? type.value : nil)
      }
    
      case node.attribute("from").value.to_sym
      when :CDATA
        
  #      nodeset = Nokogiri::XML.fragment(node.text).children
        nodeset = Nokogiri::XML::DocumentFragment.new(document, replace_tokens(node.text)).children
      else
        raise XMLProcessor::NotImplementedError.new(node.attribute("from").value)
      end
    

      self
    end
  
    def replace_tokens text
      text.gsub(/\#\{(.*?)\}/) {
        plugin.get_token($1)
      }
    end
  
  end
end