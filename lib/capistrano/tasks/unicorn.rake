# https://bogomips.org/unicorn/SIGNALS.html
namespace :unicorn do
  desc "Terminate unicorn processes (blocks until complete)"
  task :terminate do
    on roles(:app) do
      within current_path do
        kill_unicorn("SIGQUIT")
        sleep(10)
        kill_unicorn("SIGTERM")
        sleep(2)
        kill_unicorn("SIGKILL")
      end
    end
  end

  def unicorn_running?
    test("[ -f #{fetch(:unicorn_pid)} ] && pkill --count --pidfile #{fetch(:unicorn_pid)}")
  end

  def kill_unicorn(signal)
    if unicorn_running?
      execute :pkill, "--signal #{signal}", "--pidfile #{fetch(:unicorn_pid)}"
    end
  end
end
