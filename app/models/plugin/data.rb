module Plugin::Data
  extend ActiveSupport::Concern
  included do
    belongs_to :user, :class_name => "User"
    belongs_to :plugin, :class_name => "Plugin::Base"
    
    validates :name, :presence => true, :uniqueness => {:scope => [:user_id, :plugin_id]}
    validates :user, :plugin_id, :presence => true
  end
end