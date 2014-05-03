source 'http://gemcutter.org'

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
gem "rails", "~> 4.1.0"
gem "pg"
gem "kgio"
gem "dalli"
gem "delayed_job"
gem "delayed_job_active_record"
gem "simple_form"
gem "mechanize"
gem "nokogiri"
gem "whenever", :require => false
gem "sanitize"
gem 'rmagick', :require => "RMagick"
gem 'daemons'
gem 'net-ssh'
gem 'net-sftp'
gem 'newrelic_rpm'
gem 'term-ansicolor', :require => "term/ansicolor"
gem 'diff-lcs', :require => "diff/lcs/array"
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'awesome_print'
gem 'statistics2'
gem 'capistrano'
gem 'capistrano-ext'

# needed for looser jpeg header compat
gem 'ruby-imagespec', :require => "image_spec", :git => "https://github.com/r888888888/ruby-imagespec.git", :branch => "exif-fixes"

# needed for rails 4.1.0 compat
gem 'aws-s3', :require => "aws/s3", :git => "https://github.com/fnando/aws-s3.git"

group :production do
  gem 'unicorn', :platforms => :ruby
  gem 'capistrano-unicorn', :require => false
end

group :development do
  gem 'ruby-prof'
  # gem 'sql-logging'
end

