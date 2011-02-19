folder = Rails.root.join("app", "plugins")

Dir[folder.join "*.rb"].each do |file|
  require file
end
  
RProxy.plugins.each do |plugin|
  plugin.install.activate
end