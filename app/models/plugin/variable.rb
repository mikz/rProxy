class Plugin::Variable < ActiveRecord::Base
  set_table_name :plugin_variables

  include Plugin::Data
  
  def self.for(plugin, key = nil)
    scope = where(:plugin_id => plugin)
    key.present? ? scope.where(:name => key) : scope
  end
  

end
