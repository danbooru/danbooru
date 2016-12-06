namespace :delayed_job do
  desc "Start delayed_job process"
  task :start do
    on roles(:app) do
      if test("[ -d #{current_path} ]")
        within current_path do
          with rails_env: fetch(:rails_env) do
            hostname = capture("hostname").strip
            execute :bundle, "exec", "script/delayed_job", "--queues=default,#{hostname}", "-n 2", "start"
          end
        end
      end
    end
  end

  desc "Stop delayed_job process"
  task :stop do
    on roles(:app) do
      if test("[ -d #{current_path} ]")
        within current_path do
          with rails_env: fetch(:rails_env) do
            execute :bundle, "exec", "script/delayed_job", "stop"
          end
        end
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

  desc "Kill delayed_job process"
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
before "deploy:started", "delayed_job:stop"
after "deploy:published", "delayed_job:start"
