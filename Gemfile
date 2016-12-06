source 'https://rubygems.org/'

group :test do
  gem "shoulda"
  gem "factory_girl"
  gem "mocha", :require => "mocha/setup"
  gem "ffaker"
  gem "simplecov", :require => false
  gem "vcr"
  gem "webmock"
  gem "timecop"
end

gem 'protected_attributes'
gem "sass-rails", "~> 4.0.0"
gem "sprockets-rails", :require => "sprockets/railtie"
gem "uglifier"
gem 'coffee-rails'
gem "therubyracer", :platforms => :ruby
gem "pry", :group => [:test, :development]
gem "byebug", :group => [:test, :development]
gem "rails", "~> 4.2.0"
gem "pg"
gem "kgio", :platforms => :ruby
gem "dalli", :platforms => :ruby
gem "memcache-client", :platforms => [:mswin, :mingw, :x64_mingw]
gem "tzinfo-data", :platforms => [:mswin, :mingw, :x64_mingw]
gem "delayed_job"
gem "delayed_job_active_record"
gem "simple_form"
gem "mechanize"
gem "nokogiri"
gem "whenever", :require => false
gem "sanitize", "~> 3.1.0"
gem 'rmagick'
gem 'daemons'
gem 'net-ssh'
gem 'net-sftp'
gem 'term-ansicolor', :require => "term/ansicolor"
gem 'diff-lcs', :require => "diff/lcs/array", :git => "https://github.com/halostatue/diff-lcs.git"
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'awesome_print'
gem 'statistics2'
gem 'capistrano', '~> 3.4.0'
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

# needed for looser jpeg header compat
gem 'ruby-imagespec', :require => "image_spec", :git => "https://github.com/r888888888/ruby-imagespec.git", :branch => "exif-fixes"

group :production, :staging do
  gem 'unicorn', :platforms => :ruby
  gem 'capistrano3-unicorn'
end

group :production do
  gem 'unicorn-worker-killer'
  gem 'newrelic_rpm'
  gem 'gctools', :platforms => :ruby
  gem 'capistrano-deploytags', '~> 1.0.0', require: false
end

group :development do
  gem 'ruby-prof'
  # gem 'sql-logging'
end
