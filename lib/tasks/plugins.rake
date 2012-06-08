
namespace :plugins do
  desc "Finds, installs and activates plugins in FOLDER or app/plugins"
  task :install => [:'db:seed:plugins']
  
end