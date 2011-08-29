$:.unshift(File.expand_path("./lib", ENV["rvm_path"]))
set :rvm_ruby_string, "ruby-1.9.2"
set :rvm_bin_path, "/usr/local/rvm/bin"
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
set :user, "danbooru"
set :deploy_to, "/var/www/#{application}"

default_run_options[:pty] = true

desc "Change ownership of common directory to user"
task :reset_ownership_of_common_directory do
  sudo "chown -R #{user}:#{user} /var/www/danbooru"
end

namespace :deploy do
  namespace :web do
    desc "Present a maintenance page to visitors."
    task :disable do
      run "mv #{current_path}/public/maintenance2.html #{current_path}/public/maintenance.html"
    end
    
    desc "Makes the application web-accessible again."
    task :enable do
      run "mv #{current_path}/public/maintenance.html #{current_path}/public/maintenance2.html"
    end
  end
end

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

after "deploy:setup", "reset_ownership_of_common_directory"
after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
after "deploy:restart", "delayed_job:restart"

