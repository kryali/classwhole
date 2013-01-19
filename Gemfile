source 'http://rubygems.org'

gem 'rake'
gem 'rails', '3.1.10'
gem 'whenever', :require => false
gem 'passenger'
gem 'dalli'

# simulate a web browser
gem 'mechanize'

# memory logger
gem 'oink'
gem 'xml-simple'
gem 'koala', "~> 1.2.0beta"

gem 'haml'

gem 'rails3-jquery-autocomplete', '~> 0.9.1' 

gem 'icalendar'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'

gem 'rack'
gem 'rack-ssl', :require => 'rack/ssl'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
group :production do
  gem 'pg'
  gem 'mysql2'
end

group :development do
  gem 'guard'
  gem 'guard-livereload'
  gem 'sqlite3'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end
