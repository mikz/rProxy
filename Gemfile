source 'http://rubygems.org'
RAILS_VERSION = '~> 3.0.0'
DM_VERSION    = '~> 1.0.0'

gem 'rails', RAILS_VERSION
gem 'inherited_resources'
gem 'devise', :git => 'git://github.com/plataformatec/devise.git'
gem 'composite_primary_keys'

gem 'pg'
gem 'foreigner'

gem 'haml'
gem 'formtastic'

gem 'rack-fiber_pool', :require => 'rack/fiber_pool'
gem 'r_proxy', :path => "lib/r_proxy"
gem 'thin'
#gem 'rainbows'

#plugins
gem 'ri_cal'

group :development, :test do
  gem 'cucumber-rails'
  gem 'webrat'
  gem 'factory_girl_rails', '~> 1.1.beta'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'awesome_print'
  gem 'hpricot'
  
  gem 'ruby-debug19', :require => "ruby-debug"
end