namespace :unicorn do
  desc "Terminate unicorn processes (blocks until complete)"
  task :terminate do
    on roles(:app) do
      execute "[[ -n $(pgrep -f unicorn) ]] && pgrep -f unicorn | xargs kill -SIGTERM"
      sleep(5)
    end
  end

  desc "Kills unicorn processes (blocks until complete)"
  task :kill do
    on roles(:app) do
      execute "[[ -n $(pgrep -f unicorn) ]] && pgrep -f unicorn | xargs kill -SIGKILL"
    end
  end
end

after "deploy:published", "unicorn:terminate"
after "deploy:published", "unicorn:kill"
after "deploy:published", "unicorn:start"
