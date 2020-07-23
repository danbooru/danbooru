source 'https://rubygems.org/'

gem 'dotenv-rails', :require => "dotenv/rails-now"

gem "rails", "~> 6.0"
gem "pg"
gem "delayed_job"
gem "delayed_job_active_record"
gem "simple_form"
gem "whenever", :require => false
gem "sanitize"
gem 'ruby-vips'
gem 'net-sftp'
gem 'diff-lcs', :require => "diff/lcs/array"
gem 'bcrypt', :require => "bcrypt"
gem 'capistrano', '~> 3.10'
gem 'capistrano-rails'
gem 'capistrano-rbenv'
gem 'streamio-ffmpeg'
gem 'rubyzip', :require => "zip"
gem 'stripe'
gem 'aws-sdk-sqs', '~> 1'
gem 'responders'
gem 'dtext_rb', git: "https://github.com/evazion/dtext_rb.git", require: "dtext"
gem 'memoist'
gem 'daemons'
gem 'oauth2'
gem 'bootsnap'
gem 'addressable'
gem 'rakismet'
gem 'recaptcha', require: "recaptcha/rails"
gem 'activemodel-serializers-xml'
gem 'webpacker', '>= 4.0.x'
gem 'rake'
gem 'redis'
gem 'request_store'
gem 'builder'
# gem 'did_you_mean' # github.com/yuki24/did_you_mean/issues/117
gem 'puma'
gem 'scenic'
gem 'ipaddress_2'
gem 'http'
gem 'activerecord-hierarchical_query'
gem 'pundit'
gem 'mail'
gem 'nokogiri'

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
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'meta_request'
  gem 'rack-mini-profiler'
  gem 'stackprof'
  gem 'flamegraph'
  gem 'memory_profiler'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'listen'
end

group :test do
  gem "shoulda-context"
  gem "shoulda-matchers"
  gem "factory_bot"
  gem "mocha", require: "mocha/minitest"
  gem "ffaker"
  gem "simplecov", require: false
  gem "minitest-ci"
  gem "minitest-reporters", require: "minitest/reporters"
  gem "mock_redis"
  gem "capybara"
  gem "selenium-webdriver"
  gem "codecov", require: false
end
