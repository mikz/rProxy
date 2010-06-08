require "base64"

class Plugin::Isis < RProxy::Plugin
  FORMAT = :html
  
  include Worker
  
  def headers(user = self.user)
    {"Authorization" => "Basic #{Base64.encode64("#{config('username', user)}:#{config('password', user)}")}"}
  end
  
  def xml
    record = user.data.for(self, 'xml')
    record ? record.value : nil
    File.open File.join("plugins", "isis", "isis.xml")
  end
  def rng_schema
    record = user.data.for(self, 'rng_schema')
    record ? record.value : nil
    File.open File.join("plugins", "isis","schema.rng")
  end
  
  class << self
    def name
      "ISIS to iCal"
    end
    def url
      "https://isis.vse.cz/auth/student/terminy_seznam.pl"
    end
  end
end

begin
unless RProxy::Plugin.first(:name => Plugin::Isis.name)
  RProxy::Plugin.create :class_name => Plugin::Isis.to_s, :name => Plugin::Isis.name, :url => Plugin::Isis.url
end
rescue
end