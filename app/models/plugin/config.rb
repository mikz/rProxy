class Plugin::Config < Plugin::Data
  
  
  def self.for(plugin, key = nil)
    result = all(:plugin.eql => plugin)
    result.all(:key.eql => key) unless key.blank?
  end
  

end
