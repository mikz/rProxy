source 'http://rubygems.org'
RAILS_VERSION = '~> 3'
DM_VERSION    = '~> 1.0.0'
RSPEC_VERSION = '~> 2.2'

gem 'rails', RAILS_VERSION

gem 'dm-rails'

gem 'dm-postgres-adapter',  DM_VERSION
gem 'dm-migrations',        DM_VERSION
gem 'dm-types',             DM_VERSION
gem 'dm-constraints',       DM_VERSION
gem 'dm-transactions',      DM_VERSION
gem 'dm-aggregates',        DM_VERSION
gem 'dm-validations',       DM_VERSION
gem 'dm-timestamps',        DM_VERSION
gem 'dm-observer',          DM_VERSION
gem 'dm-active_model'
gem 'dm-devise'

gem 'async-rack', :path => "lib/async-rack"
gem 'rack-fiber_pool', :require => 'rack/fiber_pool'

gem 'r_proxy', :path => "lib/r_proxy"

gem 'pg'

gem 'foreigner'
gem 'haml'

gem 'clogger'

gem 'thin'
#gem 'rainbows'

group :development, :test do
  gem 'cucumber-rails'
  gem 'webrat'
  gem 'factory_girl_rails', '~> 1.1.beta'
  gem 'rspec', RSPEC_VERSION
  gem 'rspec-rails', RSPEC_VERSION
  gem 'shoulda-matchers'
  gem 'awesome_print'
  gem 'hpricot'
  
  gem 'ruby-debug19', :require => "ruby-debug"
end