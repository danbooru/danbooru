# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
require 'capistrano/rbenv'
require 'capistrano/rails'
require 'whenever/capistrano'
require 'capistrano3/unicorn'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

namespace :local_config do
  desc "Link the local config files"
  task :link_local_files do
    on roles(:app) do
      execute :ln, "-s", "#{deploy_to}/shared/config/danbooru_local_config.rb", "#{release_path}/config/danbooru_local_config.rb"
      execute :ln, "-s", "#{deploy_to}/shared/config/database.yml", "#{release_path}/config/database.yml"
      execute :ln, "-s", "#{deploy_to}/shared/config/newrelic.yml", "#{release_path}/config/newrelic.yml"
    end
  end
end

namespace :data do
  task :link_directories do
    on roles(:app) do
      execute :rm, "-f", "#{release_path}/public/data"
      execute :ln, "-s", "#{deploy_to}/shared/data", "#{release_path}/public/data"

      execute :mkdir, "-p", "#{release_path}/public/cache"
      execute :mkdir, "-p", "#{deploy_to}/shared/system/cache"
      execute :touch, "#{deploy_to}/shared/system/cache/tags.json"
      execute :ln, "-s", "#{deploy_to}/shared/system/cache/tags.json", "#{release_path}/public/cache/tags.json"
      execute :touch, "#{deploy_to}/shared/system/cache/tags.json.gz"
      execute :ln, "-s", "#{deploy_to}/shared/system/cache/tags.json.gz", "#{release_path}/public/cache/tags.json.gz"
    end
  end
end

namespace :web do
  desc "Present a maintenance page to visitors."
  task :disable do
    on roles(:app) do
      maintenance_html_path = "#{current_path}/public/maintenance.html.bak"
      if test("[ -e #{maintenance_html_path} ]")
        execute :mv, maintenance_html_path, "#{current_path}/public/maintenance.html"
      end
    end
  end

  desc "Makes the application web-accessible again."
  task :enable do
    on roles(:app) do
      maintenance_html_path = "#{current_path}/public/maintenance.html"
      if test("[ -e #{maintenance_html_path} ]")
        execute :mv, maintenance_html_path, "#{current_path}/public/maintenance.html.bak"
      end
    end
  end
end

namespace :nginx do
  desc "Shut down Nginx"
  task :stop do
    on roles(:web) do
      as :user => "root" do
        execute "/etc/init.d/nginx", "stop"
      end
    end
  end

  desc "Start Nginx"
  task :start do
    on roles(:web) do
      as :user => "root" do
        execute "/etc/init.d/nginx", "start"
      end
    end
  end

  desc "Reload Nginx"
  task :reload do
    on roles(:web) do
      as :user => "root" do
        execute "/etc/init.d/nginx", "reload"
      end
    end
  end
end

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start do
    on roles(:app) do
      within current_path do
        hostname = capture("hostname").strip
        execute :bundle, "exec", "script/delayed_job", "--queues=default,#{hostname}", "-n 2", "start"
      end
    end
  end

  desc "Stop delayed_job process"
  task :stop do
    on roles(:app) do
      within current_path do
        execute :bundle, "exec", "script/delayed_job", "stop"
      end
    end
  end

  desc "Restart delayed_job process"
  task :restart do
    on roles(:app) do
      find_and_execute_task("delayed_job:stop")
      find_and_execute_task("delayed_job:start")
    end
  end

  task :kill do
    on roles(:app) do
      procs = capture("ps -A -o pid,command").split(/\r\n|\r|\n/).grep(/delayed_job/).map(&:to_i)

      if procs.any?
        execute "for i in #{procs.join(' ')} ; do kill -s TERM $i ; done"
      end
    end
  end
end

after "delayed_job:stop", "delayed_job:kill"
after "deploy:symlink:shared", "local_config:link_local_files"
after "deploy:symlink:shared", "data:link_directories"
before "deploy:started", "web:disable"
before "deploy:started", "delayed_job:stop"
after "deploy:published", "delayed_job:start"
after "deploy:published", "unicorn:reload"
after "deploy:published", "web:enable"
