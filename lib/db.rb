require "sequel"
require 'sinatra/sequel'

require "logger"

set :database, 'postgres://postgres@localhost/rproxy_sinatra'
  
#DB = Sequel.postgres :host=>'localhost', :user=>'postgres', :password=>'', :database=>'rproxy_sinatra', :logger => Logger.new(STDERR)
migration "create users table" do
  database.create_table :users do
     primary_key :id
     varchar :login, :null => false, :unique => true
     varchar :password_hash
     varchar :salt
     varchar :proxy_key
     varchar :email, :null => false, :unique => true
     boolean :admin, :null => false, :default => false
  end
end

Dir["lib/models/*.rb"].each do |model|
  require model
end


migration "create admin user" do
  unless User.find(:admin)
    admin = User.create :login => "admin", :email => "admin@localhost", :admin => true
    admin.password = "admin"
    admin.save
  end
end




migration "create plugins table" do
  database.create_table :plugins do
    primary_key :id
    varchar :class_name
    varchar :name
    varchar :url
    boolean :active, :null => false, :default => true
  end
end

migration "create configs table" do
  database.create_table :configs do
    text :value
    varchar :key, :null => false
    primary_key [:user_id, :plugin_id, :key]
    foreign_key :user_id, {:table => :users, :on_delete => :cascade}
    foreign_key :plugin_id, {:table => :plugins, :on_delete => :cascade}
    
  end
end