class Plugin::Dpp < RProxy::Plugin
  include Worker

  def xml
    
    #record = user.data.for(self, 'xml')
    #record ? record.value : nil
    File.read(File.join(File.dirname(__FILE__), "dpp", "actions.xml"))
  end
  
  def rng_schema
    #record = user.data.for(self, 'rng_schema')
    #record ? record.value : nil
    File.read(File.join(File.dirname(__FILE__), "dpp", "schema.rng"))
  end
  
  ## Plugin methods
  def test_call element
    #DEBUG {%w{element}}
  end
  
  class << self
    def name
      "Dpp.cz IDOS"
    end
    def url
      "http://idos.dpp.cz/idos/"
    end
  end
end
