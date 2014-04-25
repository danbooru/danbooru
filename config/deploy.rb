set :stages, %w(production staging)
set :default_stage, "staging"
set :unicorn_env, defer {stage}
require 'capistrano/ext/multistage'

require 'bundler/capistrano'
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby"

set :default_environment, {
  "PATH" => '$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH'
}

set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer {stage}
require 'whenever/capistrano'

require 'securerandom'
set :secret_1, SecureRandom.base64(32)
set :secret_2, SecureRandom.base64(32)

set :application, "danbooru"
set :repository,  "git://github.com/r888888888/danbooru.git"
set :scm, :git
set :user, "albert"
set :deploy_to, "/var/www/danbooru2"

require 'capistrano-unicorn'

default_run_options[:pty] = true

namespace :local_config do
  desc "Create the shared config directory"
  task :setup_shared_directory do
    run "mkdir -p #{deploy_to}/shared/config"
  end

  desc "Initialize the secrets"
  task :setup_secrets do
    run "mkdir -p ~/.danbooru"
    run "if [[ ! -e ~/.danbooru/session_secret_key ]] ; then echo '#{secret_1}' > ~/.danbooru/session_secret_key ; fi"
    run "if [[ ! -e ~/.danbooru/secret_token ]] ; then echo '#{secret_2}' > ~/.danbooru/secret_token ; fi"
    run "chmod 600 ~/.danbooru/secret_token"
    run "chmod 600 ~/.danbooru/session_secret_key"
    run "chown -R #{user}:#{user} ~/.danbooru"
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
    run "ln -s #{deploy_to}/shared/config/newrelic.yml #{release_path}/config/newrelic.yml"
  end
end

namespace :data do
  task :setup_directories do
    run "mkdir -p #{deploy_to}/shared/data"
    run "mkdir #{deploy_to}/shared/data/preview"
    run "mkdir #{deploy_to}/shared/data/sample"
  end

  task :link_directories do
    run "rm -f #{release_path}/public/data"
    run "ln -s #{deploy_to}/shared/data #{release_path}/public/data"

    run "rm -f #{release_path}/public/images/advertisements"
    run "ln -s #{deploy_to}/shared/advertisements #{release_path}/public/images/advertisements"

    run "mkdir -p #{release_path}/public/cache"
    run "mkdir -p #{deploy_to}/shared/system/cache"
    run "touch #{deploy_to}/shared/system/cache/tags.json"
    run "ln -s #{deploy_to}/shared/system/cache/tags.json #{release_path}/public/cache/tags.json" 
    run "touch #{deploy_to}/shared/system/cache/tags.json.gz"
    run "ln -s #{deploy_to}/shared/system/cache/tags.json.gz #{release_path}/public/cache/tags.json.gz"
  end
end

desc "Change ownership of common directory to user"
task :reset_ownership_of_common_directory do
  sudo "chown -R #{user}:#{user} #{deploy_to}"
end

namespace :deploy do
  namespace :web do
    desc "Present a maintenance page to visitors."
    task :disable do
      maintenance_html_path = "#{current_path}/public/maintenance.html.bak"
      run "if [ -e #{maintenance_html_path} ] ; then mv #{maintenance_html_path} #{current_path}/public/maintenance.html ; fi"
    end

    desc "Makes the application web-accessible again."
    task :enable do
      maintenance_html_path = "#{current_path}/public/maintenance.html"
      run "if [ -e #{maintenance_html_path} ] ; then mv #{maintenance_html_path} #{current_path}/public/maintenance.html.bak ; fi"
    end
  end

  namespace :nginx do
    desc "Shut down Nginx"
    task :stop do
      sudo "/etc/init.d/nginx stop"
    end

    desc "Start Nginx"
    task :start do
      sudo "/etc/init.d/nginx start"
    end
  end

  desc "Precompiles assets"
  task :precompile_assets do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
    # run "cd #{current_path}/public/assets; cp application-*.js application.js ; cp application-*.css application.css"
  end
end

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec ruby script/delayed_job --queues=default,`hostname` start"
  end

  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec ruby script/delayed_job stop"
  end

  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    find_and_execute_task("delayed_job:stop")
    find_and_execute_task("delayed_job:start")
  end

  task :kill, :roles => :app do
    procs = capture("ps -A -o pid,command").split(/\r\n|\r|\n/).grep(/delayed_job/).map(&:to_i)

    if procs.any?
      run "for i in #{procs.join(' ')} ; do kill -SIGTERM $i ; done"
    end
  end
end

after "deploy:setup", "reset_ownership_of_common_directory"
after "deploy:setup", "local_config:setup_shared_directory"
after "deploy:setup", "local_config:setup_local_files"
after "deploy:setup", "data:setup_directories"
after "deploy:setup", "local_config:setup_secrets"
after "deploy:create_symlink", "local_config:link_local_files"
after "deploy:create_symlink", "data:link_directories"
after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
before "deploy:update", "deploy:web:disable"
after "deploy:update", "delayed_job:restart"
after "deploy:update", "deploy:migrate"
after "deploy:update", "unicorn:reload"
after "deploy:update", "unicorn:restart"
after "deploy:update", "deploy:precompile_assets"
after "deploy:update", "deploy:web:enable"
after "delayed_job:stop", "delayed_job:kill"
