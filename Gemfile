source 'https://rubygems.org'

gem 'aws-sdk', '~> 1.14.1'
gem 'area', '~> 0.10.0'
gem "audited-activerecord", "4.0.0.rc1"
gem 'carmen', '~> 1.0.0'
gem 'daemons', '~> 1.1.9'
gem 'devise', '~> 3.3.0'
gem 'delayed_job', '~> 4.0.1'
gem 'delayed_job_active_record', '~> 4.0.1'
gem 'exception_notification', '~> 4.0.0'
gem 'holidays','~> 1.0.5'
gem 'flot-rails'
gem 'kaminari', '~> 0.14.1'
gem 'mysql2', '~> 0.3.14'
gem 'nokogiri'
gem 'paperclip', '~> 4.2.0'
gem 'premailer-rails', '~> 1.8.0'
gem 'psych', '~> 1.3.4'
gem 'rails', '4.1.13'
gem 'ransack', '~> 1.3.0'
gem 'redis-objects', '~> 0.5.3'
gem 'rest-client', '~> 1.6.9'
gem 'savon', '~> 2.5.1'
gem 'stripe', '~> 1.22.0'
gem 'unicorn'

# Assets
gem 'autoprefixer-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'sass',       '~> 3.4.12'
gem 'sass-rails', '~> 5.0.1'
gem 'uglifier',   '>= 1.3.0'

gem 'intercom'

# Helpers
gem 'nav_lynx'

group :test, :development do
  gem 'byebug'
end

group :test do
  gem 'factory_girl', '~> 4.1.0'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'mocha', require: nil
  gem 'shoulda'
  gem 'shoulda-matchers', require: nil
  gem 'timecop'
  gem 'simplecov', :require => false
  gem 'stripe-ruby-mock', require: 'stripe_mock'
end

group :development do
  gem 'rubocop'
  gem 'spring'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  # Guard
  gem 'guard'
  gem 'guard-livereload', require: false
  gem 'guard-pow', require: false
end

group :development, :staging do
  gem 'capistrano', '3.4.0',        require: false
  gem 'capistrano-rails', '~> 1.1.3', require: false
end
