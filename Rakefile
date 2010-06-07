# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

#require(File.join(File.dirname(__FILE__), 'rproxy'))
require "rproxy"

task :migrate do
  DataMapper.auto_migrate!
  unless User.get(:admin)
    admin = User.new :login => "admin", :email => "admin@localhost", :admin => true, :password => "admin"
    admin.save
  end
end
