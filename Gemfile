source 'https://rubygems.org/'

gem 'dotenv-rails', :require => "dotenv/rails-now"

gem "sass-rails"
gem "uglifier"
gem "therubyracer", :platforms => :ruby
gem "rails", "~> 5.2"
gem "pg"
gem "dalli", :platforms => :ruby
gem "memcache-client", :platforms => [:mswin, :mingw, :x64_mingw]
gem "tzinfo-data", :platforms => [:mswin, :mingw, :x64_mingw]
gem "delayed_job"
gem "delayed_job_active_record"
gem "simple_form"
gem "mechanize"
gem "whenever", :require => false
gem "sanitize"
gem 'ruby-vips'
gem 'net-sftp'
gem 'term-ansicolor', :require => "term/ansicolor"
gem 'diff-lcs', :require => "diff/lcs/array"
gem 'bcrypt', :require => "bcrypt"
gem 'statistics2'
gem 'capistrano', '~> 3.10'
gem 'capistrano-rails'
gem 'capistrano-rbenv'
gem 'radix62', '~> 1.0.1'
gem 'streamio-ffmpeg'
gem 'rubyzip', :require => "zip"
gem 'stripe'
gem 'twitter'
gem 'aws-sdk', '~> 2'
gem 'responders'
gem 'highline'
gem 'dtext_rb', :git => "https://github.com/r888888888/dtext_rb.git", :require => "dtext"
gem 'google-api-client'
gem 'cityhash'
gem 'bigquery', :git => "https://github.com/abronte/BigQuery.git", :ref => "b92b4e0b54574e3fde7ad910f39a67538ed387ad"
gem 'memcache_mock'
gem 'memoist'
gem 'daemons'
gem 'oauth2'
gem 'bootsnap'
gem 'addressable'
gem 'httparty'
gem 'rakismet'
gem 'recaptcha', require: "recaptcha/rails"
gem 'activemodel-serializers-xml'
gem 'ptools'
gem 'jquery-rails'
gem 'webpacker', '>= 4.0.x'
gem 'retriable'

# needed for looser jpeg header compat
gem 'ruby-imagespec', :require => "image_spec", :git => "https://github.com/r888888888/ruby-imagespec.git", :branch => "exif-fixes"

group :production, :staging do
  gem 'unicorn', :platforms => :ruby
  gem 'capistrano3-unicorn'
end

group :production do
  gem 'unicorn-worker-killer'
  gem 'newrelic_rpm'
  gem 'capistrano-deploytags', '~> 1.0.0', require: false
end

group :development do
  gem 'sinatra'
end

group :development, :test do
  gem 'awesome_print'
  gem 'pry-byebug'
  gem 'ruby-prof'
  gem 'foreman'
  gem 'listen'
end

group :test do
  gem "shoulda-context"
  gem "shoulda-matchers"
  gem "factory_bot"
  gem "mocha", :require => "mocha/setup"
  gem "ffaker"
  gem "simplecov", :require => false
  gem "timecop"
  gem "webmock"
  gem "minitest-ci"
end
