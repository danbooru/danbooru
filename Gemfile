source 'http://gemcutter.org'

group :test do
  gem "shoulda"
  gem "factory_girl"
  gem "mocha", :require => "mocha/setup"
  gem "ffaker", :git => "http://github.com/EmmanuelOga/ffaker.git"
  gem "simplecov", :require => false
  gem "pry"
  gem "vcr"
  gem "webmock"
  gem "timecop"
end

group :assets do
  gem "sass-rails"
  gem "uglifier", ">= 1.0.3"
  gem "therubyracer", :platforms => :ruby
end

gem "rails", "3.2.12"
gem "pg", "0.12.2"
gem "memcache-client", :require => "memcache"
gem "delayed_job"
gem "delayed_job_active_record"
gem "simple_form"
gem "mechanize", :git => 'git://github.com/caribio/mechanize.git'
gem "nokogiri"
gem "whenever", :require => false
gem "sanitize", :git => "git://github.com/rgrove/sanitize.git"
gem 'rmagick', :require => "RMagick"
gem 'daemons'
gem 'net-ssh'
gem 'net-sftp'
gem 'newrelic_rpm'
gem 'term-ansicolor', :require => "term/ansicolor"
gem 'diff-lcs', :require => "diff/lcs/array"
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'aws-s3', :require => "aws/s3"
gem 'awesome_print'
gem 'statistics2'
gem 'ruby-imagespec', :require => "image_spec"

group :production do
  gem 'unicorn', :platforms => :ruby
  gem 'capistrano-unicorn', :require => false
end

group :development do
  gem 'ruby-prof'
  gem 'pry'
end

