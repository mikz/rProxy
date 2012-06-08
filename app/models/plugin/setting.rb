class Plugin::Setting < ActiveRecord::Base
  set_table_name :plugin_settings

  include Plugin::Data

  def xml?
    self[:name] =~ /xml|schema/i
  end
  
  
  def self.for(plugin, name)
    where(:plugin_id => plugin, :name => name)
  end
  
end
