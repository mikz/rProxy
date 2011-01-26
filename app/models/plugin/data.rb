class Plugin::Data

  include DataMapper::Resource
  
  property :name , String, :key => true, :required => true
  property :user_login, String, :key => true, :required => true
  property :plugin_id, Integer, :key => true, :required => true
  property :value, Text
  
  belongs_to :user, :model => "User"
  belongs_to :plugin, :model => "Plugin::Base"
  
  property :id, Serial

  def xml?
    self[:name] =~ /xml|schema/i
  end
  
  
  def self.for(plugin, name)
    result = all(:plugin.eql => plugin)
    result.first(:name.eql => name)
  end
  
end
