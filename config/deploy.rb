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

namespace :local_config do
  desc "Create the shared config directory"
  task :setup_shared_directory do
    run "mkdir -p #{deploy_to}/shared/config"
  end

  desc "Initialize local config files"
  task :setup_local_files do
    run "curl -s https://raw.github.com/r888888888/danbooru/master/script/install/danbooru_local_config.rb.templ > #{deploy_to}/shared/config/danbooru_local_config.rb"
    run "curl -s https://raw.github.com/r888888888/danbooru/master/script/install/database.yml.templ > #{deploy_to}/shared/config/database.yml"
  end

  desc "Link the local config files"
  task :link_local_files do
    run "ln -s #{deploy_to}/shared/config/danbooru_local_config.rb #{release_path}/config/danbooru_local_config.rb"
    run "ln -s #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end
end

namespace :data do
  task :setup_directories do
    run "mkdir -p #{deploy_to}/shared/data"
    run "mkdir #{deploy_to}/shared/data/preview"
    run "mkdir #{deploy_to}/shared/data/small"
    run "mkdir #{deploy_to}/shared/data/large"
    run "mkdir #{deploy_to}/shared/data/original"
  end
  
  task :link_directories do
    run "rm -f #{release_path}/public/data"
    run "ln -s #{deploy_to}/shared/data #{release_path}/public/data"
  end
end

desc "Change ownership of common directory to user"
task :reset_ownership_of_common_directory do
  sudo "chown -R #{user}:#{user} /var/www/danbooru"
end

namespace :deploy do
  namespace :web do
    desc "Present a maintenance page to visitors."
    task :disable do
      maintenance_html_path = "#{release_path}/public/maintenance.html.bak"
      run "if [ -e #{maintenance_html_path} ] ; then mv #{maintenance_html_path} #{release_path}/public/maintenance.html ; fi"
    end
    
    desc "Makes the application web-accessible again."
    task :enable do
      maintenance_html_path = "#{release_path}/public/maintenance.html"
      run "if [ -e #{maintenance_html_path} ] ; then mv #{maintenance_html_path} #{release_path}/public/maintenance.html.bak ; fi"
    end
  end
  
  desc "Compile the image resizer"
  task :compile_image_resizer do
    run "cd #{release_path}/lib/danbooru_image_resizer ; ruby extconf.rb ; make"
  end
end

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    run "cd #{release_path}; script/delayed_job start #{rails_env}"
  end
  
  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    run "cd #{release_path}; script/delayed_job stop #{rails_env}"
  end
  
  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    run "cd #{release_path}; script/delayed_job restart #{rails_env}"
  end
end

after "deploy:setup", "reset_ownership_of_common_directory"
after "deploy:setup", "local_config:setup_shared_directory"
after "deploy:setup", "local_config:setup_local_files"
after "deploy:setup", "data:setup_directories"
after "deploy:update_code", "local_config:link_local_files"
after "deploy:update_code", "data:link_directories"
after "deploy:update_code", "deploy:compile_image_resizer"
after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
after "deploy:restart", "delayed_job:restart"
before "deploy:update", "deploy:web:disable"
after "deploy:restart", "deploy:web:enable"
