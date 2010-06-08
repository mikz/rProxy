require "openssl"
require "lib/utf8"

class User
  include DataMapper::Resource
  include UTF8Attributes
  
  property :login, String, :key => true, :required => true
  property :password_hash, String, :length => 256
  property :salt, String, :length => 256
  property :proxy_key, String, :length => 256
  property :email, String, :required => true, :unique => true
  property :admin, Boolean, :required => true, :default => false
  
  has n, :data, :model => "User::Data"
  has n, :configs, :model => "User::Config"
  
  PUBLIC_KEY = OpenSSL::PKey::RSA.new(File.read("certs/public.pem"))
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(File.read("certs/private.pem"))
  PROXY_KEY_LENGTH = 32
  DELIMITER = "--"
  attr_accessor :password
  
  before :save, :encrypt_password
  before :save, :gen_proxy_key
  
  def id
    self.key.first
  end
  
  def get_config plugin, name
    self.configs.first(:plugin.eql => plugin, :name.eql => name)
  end
  # Encrypts data using instance salt.
  def encrypt(data)
    self.class.encrypt(data, salt)
  end
  
  def encrypt_url(plugin_id, url, method = "G", data = {})
    data_array = []
    data.each_pair do |key, val|
      data_array.push "#{key}=#{val}"
    end
    
    url = [plugin_id.to_i, method[0,1], url, data_array.join(";") ].join(DELIMITER)
    
    @key ||= EzCrypto::Key.with_password self.proxy_key, salt
    url = "#{DELIMITER}#{self.id}#{DELIMITER}#{@key.encrypt(url)}"
    self.class.encrypt_url(url)
  end

  def decrypt_url(string)
    @key ||= EzCrypto::Key.with_password proxy_key, salt
    string = @key.decrypt string
    regex = /^(\d)--(P|G)--(.+?)--(?:(.+)?)$/i
    match = regex.match string
    data = {}
    match[4].split(";").each { |line|
      line = line.split("=")
      data[line.first] = line.last
    } unless match[4].blank?
    data = {:user => self, :user_id => self.id, :plugin_id => match[1], :plugin => RProxy::Plugin.with_class(match[1].to_i), :method => match[2], :url => match[3], :data => data }
  end
  
  def authenticated?(password)
    self.password_hash == encrypt(password)
  end

  class << self
    def find *args
      if args.length == 1
        get *args
      else
        find *args
      end
    end
    
    def decrypt_url(string)
#      string = PRIVATE_KEY_KEY.private_decrypt(Base32.decode string)
      string = PRIVATE_KEY.private_decrypt([string].pack("H*"))
      parts = string.split(DELIMITER)
      if parts.shift.blank?
        id = parts.shift.to_i
        string = parts.join(DELIMITER)
        STDERR << %{
          ID, STR : #{[id, string].inspect}
        }
        return User[id].decrypt_url string
      else
        raise "Error! (Bad url)"
      end
    end

    def encrypt_url(string)
#      CGI.escape(Base64.encode64(PUBLIC_KEY.public_encrypt(string)))
#      Base32.encode(PUBLIC_KEY.public_encrypt(string))
      PUBLIC_KEY.public_encrypt(string).unpack("H*").join
    end
    
    # Encrypts data using a given salt.
    # Uses SHA256 for encryption.
    def encrypt(data, salt)
      Digest::SHA256.hexdigest([salt, data].join DELIMITER)
    end
    
    def authenticate(login, password)
      user = self.get(login.downcase.to_s)
      user && user.authenticated?(password) ? user : false
    end
  end
  
  protected
  # Encrypts password and generates salt.
  def encrypt_password
    return if !password || password.empty?
    self.salt = Digest::SHA256.hexdigest("#{DELIMITER}#{Time.now.to_s}#{DELIMITER}#{login}#{DELIMITER}") if !self.salt
    self.password_hash = encrypt(password)
  end

  def gen_proxy_key
    return if proxy_key && proxy_key.length == PROXY_KEY_LENGTH
    srand
    seed = "#{DELIMITER}#{rand(10000)}#{DELIMITER}#{Time.now}#{DELIMITER}"
    hash = Digest::SHA512.hexdigest(seed)
    self.proxy_key = hash[rand(hash.length-PROXY_KEY_LENGTH),PROXY_KEY_LENGTH]
  end
  
end