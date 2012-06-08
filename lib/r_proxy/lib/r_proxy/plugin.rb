module RProxy
  module Plugin
    extend ActiveSupport::Concern
    
    include Worker
    
    included do
      class_inheritable_accessor :token_delim
      self.token_delim = "."
    end
    
    def options; {}; end
    
    def url_for_user user
      user.encrypt_url self.id, self.url
    end

    def get_token key
      tokens = key.split(self.class.token_delim)
      case tokens.shift.to_sym
      when :config
        config(tokens.join(self.class.token_delim))
      end

    end

    def config key, user = self.user
      config = user.get_config(self, key)
      config ? config.value : nil
    end
    
    def activate
      self.update_attribute :active, true
    end
    
    module ClassMethods
      def inherited(subclass)
        super
        RProxy.plugins << subclass
      end

      def with_class id
        record = self.find id
        klass = record.class_name.constantize
        klass.find id
      end

      def install
        self.create :class_name => self.to_s, :name => self.label, :url => self.url
      end
      
    end
  end
end