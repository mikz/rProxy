namespace :plugins do
  desc "Finds, installs and activates plugins in FOLDER or app/plugins"
  task :install => [:environment] do
    folder = ENV['FOLDER'].presence || File.join("app", "plugins")
    Dir[File.join(".", folder, "*.rb")].each do |file|
      puts file
      require file
    end
    
    RProxy.plugins.each do |plugin|
      plugin.install.activate
    end
    
  end
end