class Plugin::Dpp < RProxy::Plugin
  class << self
    def name
      "Dpp.cz IDOS"
    end
    def url
      "http://idos.dpp.cz/idos/"
    end
  end
end


unless RProxy::Plugin.find(:name => Plugin::Dpp.name)
  RProxy::Plugin.insert :class_name => Plugin::Dpp.to_s, :name => Plugin::Dpp.name, :url => Plugin::Dpp.url
end