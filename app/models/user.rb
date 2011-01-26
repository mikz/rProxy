class User

  include DataMapper::Resource
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  property :id, Serial, :key => true
  property :salt, String, :length => 256
  property :proxy_key, String, :length => 256
  property :admin, Boolean, :required => true, :default => false

  has n, :data, :model => "Plugin::Data"
  has n, :configs, :model => "Plugin::Config"
  
  include RProxy::User

end