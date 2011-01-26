module RProxy
  module User
    extend ActiveSupport::Concern
    
    included do
      PUBLIC_KEY = OpenSSL::PKey::RSA.new(File.read("certs/public.pem"))
      PRIVATE_KEY = OpenSSL::PKey::RSA.new(File.read("certs/private.pem"))
      PROXY_KEY_LENGTH = 32
      DELIMITER = "--"

      before :save, :gen_proxy_key
      
    end
      
    module ClassMethods
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
          return self.find(id).decrypt_url string
        else
          raise "Error! (Bad url)"
        end
      end

      def encrypt_url(string)
  #      CGI.escape(Base64.encode64(PUBLIC_KEY.public_encrypt(string)))
  #      Base32.encode(PUBLIC_KEY.public_encrypt(string))
        PUBLIC_KEY.public_encrypt(string).unpack("H*").join
      end

      # Encrypts data using a given key.
      # Uses SHA256 for encryption.
      def encrypt(data, key)
        Digest::SHA256.hexdigest([key, data].join DELIMITER)
      end
    end
    
    def get_config plugin, name
      self.configs.first(:plugin.eql => plugin, :name.eql => name)
    end
    # Encrypts data using instance key.
    def encrypt(data, key = self.proxy_key)
      self.class.encrypt(data, key)
    end

    def encrypt_url(plugin_id, url, method = "G", data = {})
      data_array = []
      data.each_pair do |key, val|
        data_array.push "#{key}=#{val}"
      end

      url = [plugin_id.to_i, method[0,1], url, data_array.join(";") ].join(DELIMITER)
      
      @key ||= ::EzCrypto::Key.with_password self.proxy_key, self.password_salt
      url = "#{DELIMITER}#{self.id}#{DELIMITER}#{@key.encrypt(url)}"
      self.class.encrypt_url(url)
    end

    def decrypt_url(string)
      @key ||= ::EzCrypto::Key.with_password proxy_key, self.password_salt
      string = @key.decrypt string
      regex = /^(\d)--(P|G)--(.+?)--(?:(.+)?)$/i
      match = regex.match string
      data = {}
      match[4].split(";").each { |line|
        line = line.split("=")
        data[line.first] = line.last
      } unless match[4].blank?
      data = {:user => self, :user_id => self.id, :plugin_id => match[1], :plugin => RProxy.plugin_model.with_class(match[1].to_i), :method => match[2], :url => match[3], :data => data }
    end

protected
    def gen_proxy_key
      return if proxy_key && proxy_key.length == PROXY_KEY_LENGTH
      srand
      seed = "#{DELIMITER}#{rand(10000)}#{DELIMITER}#{Time.now}#{DELIMITER}"
      hash = Digest::SHA512.hexdigest(seed)
      self.proxy_key = hash[rand(hash.length-PROXY_KEY_LENGTH),PROXY_KEY_LENGTH]
    end
  end
end