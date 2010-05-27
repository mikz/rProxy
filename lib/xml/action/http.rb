class XMLProcessor::Action::Http < XMLProcessor::Action
  def initialize node, document, &block
    super(node, document, block.binding)
    
    method = node.attribute("method").value
    url = node.attribute("url").value
    params = {}
    key = nil
    node.search("./xmlns:data/*", node.namespaces).each do |elem|
      case elem.name.to_sym
      when :param
        params[elem.attribute("name").value] = elem.text
      when :key
        key = elem.text
      when :value
        params[key] = elem.text
      else
        raise XMLProcessor::NotImplementedError.new(param.name.to_sym)
      end
    end
    
    DEBUG {%w{params method}}
    request = Typhoeus::Request.new(url.to_s, :method => method, :params => params)
    DEBUG {%w{request}}
    request.on_complete do |response|

      plugin = decrypted[:plugin]

      plugin.process response.body, current_user, url, app_path
      body plugin.output
    end
    
    HYDRA.queue request
    HYDRA.run
    @element = element_from(nodeset)
    
    block[self]

    self
  end

end