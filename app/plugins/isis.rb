require "base64"

class Isis < Plugin::Base
  FORMAT = :html
  
  def headers(user = self.user)
    {"Authorization" => "Basic #{Base64.encode64("#{config('username', user)}:#{config('password', user)}")}"}
  end
  
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
      "ISIS to iCal"
    end
    def url
      "https://isis.vse.cz/auth/student/terminy_seznam.pl"
    end
  end
end