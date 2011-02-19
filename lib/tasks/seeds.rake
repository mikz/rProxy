namespace :db do
  namespace :seed do
    
    Dir[File.join %w{db seeds *.rb}].each do |file|
      name = File.basename(file, ".rb")
      desc "Load the seed data from #{file}"
      task name => :environment do
        require Rails.root.join(file)
      end
      
    end
  end
end
