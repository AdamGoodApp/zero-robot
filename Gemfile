source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'mysql2'
gem 'rails', '>= 5.0.0.rc2', '< 5.1'
gem 'puma'
gem 'redis', '~>3.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'figaro'
gem "cancan"
gem 'pry-rails'
gem 'ci_reporter_rspec'
gem 'stackprof', '~> 0.2.7'


### General
# Auth framework
gem 'devise'

### Motion planning
# To load motion planning library
gem 'ffi'
# To detect current OS (motion planning library)
gem 'os'

### Embedded
# For protocol generation/management
gem 'google-protobuf'
# For Embedded communication
gem 'rbczmq'

### Assets
# Use assets pipeline to generate errors
gem 'error_page_assets'

## JavaScript
gem 'react-rails'


### Debug
group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'capistrano-rails'
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-thin', '~> 1.2.0'
  gem 'meta_request'
end


### Tests
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry'
  gem 'rb-readline'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'

  # Test framework
  gem 'rspec'

  # Needed for Rails 5
  gem 'rails-controller-testing'

  # Mocks
  gem "fakeredis"

  # Guard & plugins
  gem 'guard', '>= 2.2.2', require: false
  gem 'guard-bundler', require: false
  gem 'guard-rspec', require: false

  # Notifications for Guard
  gem 'terminal-notifier-guard' # Install 'terminal-notifier' to get notifications (`brew install terminal-notifier`)

  # Add live reload capabilities (need no browser extension, launch `guard -P livereload` and reload the page)
  gem 'guard-livereload', require: false
  gem 'rack-livereload'
  gem 'rb-fsevent', require: false

  # For JUnit output in RSpec
  gem 'yarjuf'

  # Tests Coverage
  gem 'simplecov'
  gem 'simplecov-csv'
end
