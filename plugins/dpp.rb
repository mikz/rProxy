class Plugin::Dpp < RProxy::Plugin
  include Worker
  

  def xml
    record = user.data.for(self, 'xml')
    record ? record.value : nil
  end
  def rng_schema
    record = user.data.for(self, 'rng_schema')
    record ? record.value : nil
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

begin
unless RProxy::Plugin.first(:name => Plugin::Dpp.name)
  RProxy::Plugin.create :class_name => Plugin::Dpp.to_s, :name => Plugin::Dpp.name, :url => Plugin::Dpp.url
end
rescue
end