class Shortcut < ActiveRecord::Base
  validates :user, :plugin_id, :presence => true
  validates :query, :uniqueness => true
  
  belongs_to :user
  belongs_to :plugin, :class_name => "Plugin::Base"
end
