class User::Config
  include DataMapper::Resource
  
  include UTF8Attributes
  
  property :name , String, :key => true, :required => true
  property :user_login, String, :key => true, :required => true
  property :plugin_id, Integer, :key => true, :required => true
  property :value, Text
  
  belongs_to :user, :model => "User"
  belongs_to :plugin, :model => "RProxy::Plugin"
  
  validates_presence_of :user, :plugin, :name
  
  def id
    (self.key) ? self.key.join(",") : nil
  end
  
  def self.for(plugin, key = nil)
    result = all(:plugin.eql => plugin)
    result.all(:key.eql => key) unless key.blank?
  end
  
  def xml?
    self[:name] =~ /xml|schema/i
  end
end