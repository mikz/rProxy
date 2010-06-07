class Plugin::Isis < RProxy::Plugin
  FORMAT = :xhtml
  
  include Worker
  
  class << self
    def name
      "ISIS to iCal"
    end
    def url
      "https://isis.vse.cz/auth/"
    end
  end
end

begin
unless RProxy::Plugin.first(:name => Plugin::Isis.name)
  RProxy::Plugin.create :class_name => Plugin::Isis.to_s, :name => Plugin::Isis.name, :url => Plugin::Isis.url
end
rescue
end