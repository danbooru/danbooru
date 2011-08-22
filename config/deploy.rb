$:.unshift(File.expand_path("./lib", ENV["rvm_path"]))
set :rvm_ruby_string, "ruby-1.9.2"
require 'rvm/capistrano'

set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

require 'bundler/capistrano'

set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer {stage}
require 'whenever/capistrano'

set :application, "danbooru"
set :repository,  "git://github.com/r888888888/danbooru.git"
set :scm, :git
set :deploy_to, "/var/www/#{application}"

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; script/delayed_job start #{rails_env}"
  end
  
  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path}; script/delayed_job stop #{rails_env}"
  end

  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path}; script/delayed_job restart #{rails_env}"
  end
end

after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
after "deploy:restart", "delayed_job:restart"
