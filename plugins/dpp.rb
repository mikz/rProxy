class Plugin::Dpp < RProxy::Plugin
  include Worker
  
  class << self
    def name
      "Dpp.cz IDOS"
    end
    def url
      "http://idos.dpp.cz/idos/"
    end
    
    def xml
      File.open File.join(File.dirname(__FILE__), "dpp", "dpp.xml")
    end
    def rng_schema
      File.open File.join(File.dirname(__FILE__), "dpp", "schema.rng")
    end
  end
end


unless RProxy::Plugin.find(:name => Plugin::Dpp.name)
  RProxy::Plugin.insert :class_name => Plugin::Dpp.to_s, :name => Plugin::Dpp.name, :url => Plugin::Dpp.url
end