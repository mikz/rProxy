class User < ActiveRecord::Base
  # include DataMapper::Resource
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

#  attr_accessible :email, :password, :password_confirmation, :remember_me
  
#  property :id, Serial, :key => true
#  property :salt, String, :length => 256
#  property :proxy_key, String, :length => 256
 # property :admin, Boolean, :required => true, :default => false
 
  has_many :variables, :class_name => "Plugin::Variable"
  has_many :settings, :class_name => "Plugin::Setting"
  has_many :shortcuts
  
  include RProxy::User
  
  def to_label
    email
  end
end