require "sequel"
require "logger"

DB = Sequel.postgres :host=>'localhost', :user=>'postgres', :password=>'', :database=>'rproxy_sinatra', :logger => Logger.new(STDERR)

DB.create_table :users do
   primary_key :id
   varchar :login, :null => false, :unique => true
   varchar :password_hash
   varchar :salt
   varchar :proxy_key
   varchar :email, :null => false, :unique => true
   boolean :admin, :null => false, :default => false
end unless DB.table_exists? :users

require "models/user"

unless User.find(:admin)
  admin = User.new :login => :admin, :email => "admin@localhost", :admin => true
  admin.password = "admin"
  admin.save
end


DB.create_table :plugins do
  primary_key :id
  varchar :class_name
  varchar :name
  varchar :url
  boolean :active, :null => false, :default => true
end unless DB.table_exists? :plugins