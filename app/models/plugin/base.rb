class Plugin::Base

  
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :class_name, String, :required => true
  property :name, String, :required => true
  property :url, String, :length => 255, :required => true
  property :active, Boolean, :required => true, :default => false
  
  
  include RProxy::Plugin

end
