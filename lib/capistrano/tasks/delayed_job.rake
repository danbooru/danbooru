namespace :delayed_job do
  desc "Start delayed_job process"
  task :start do
    on roles(:worker) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          fetch(:delayed_job_workers, 16).times do |n|
            bundle = SSHKit.config.command_map[:bundle]
            execute :"systemd-run", "--user --collect --slice delayed_job --unit delayed_job.#{n} -E RAILS_ENV=$RAILS_ENV -p WorkingDirectory=$PWD -p Restart=always #{bundle} exec script/delayed_job --queues=default run"
          end
        end
      end
    end
  end

  desc "Stop delayed_job process"
  task :stop do
    on roles(:worker) do
      execute :systemctl, "--user stop delayed_job.slice"
    end
  end

  desc "Restart delayed_job process"
  task :restart do
    on roles(:worker) do
      execute :systemctl, "--user restart delayed_job.slice"
    end
  end

  desc "Show status of delayed_job process"
  task :status do
    on roles(:worker) do
      # systemctl exits with status 3 if the service isn't running.
      execute :systemctl, "--user status delayed_job.slice", raise_on_non_zero_exit: false
    end
  end
end
