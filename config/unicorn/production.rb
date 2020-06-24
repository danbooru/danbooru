# Set your full path to application.
app_path = "/var/www/danbooru2/current"

# Set unicorn options
worker_processes 20

timeout 180
# listen "127.0.0.1:9000", :tcp_nopush => true
listen "/tmp/.unicorn.sock", backlog: 1024

# Spawn unicorn master worker for user apps (group: apps)
user 'danbooru', 'danbooru'

# Fill path to your app
working_directory app_path

# Should be 'production' by default, otherwise use other env
rails_env = ENV['RAILS_ENV'] || 'production'

# Log everything to one file
stderr_path "/dev/null"
stdout_path "/dev/null"

# Set master PID location
pid "#{app_path}/tmp/pids/unicorn.pid"

# combine Ruby 2.0.0+ with "preload_app true" for memory savings
preload_app true

# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application.  This
# prevents calling the application for connections that have disconnected
# while queued.  This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

# local variable to guard against running a hook multiple times
run_once = true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  # Occasionally, it may be necessary to run non-idempotent code in the
  # master before forking.  Keep in mind the above disconnect! example
  # is idempotent and does not need a guard.
  if run_once
    # do_something_once_here ...
    run_once = false # prevent from firing again
  end

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # # This allows a new master process to incrementally
  # # phase out the old master process with SIGTTOU to avoid a
  # # thundering herd (especially in the "preload_app false" case)
  # # when doing a transparent upgrade.  The last worker spawned
  # # will then kill off the old master process with a SIGQUIT.
  # old_pid = "#{server.config[:pid]}.oldbin"
  # if old_pid != server.pid
  #   begin
  #     sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
  #     Process.kill(sig, File.read(old_pid).to_i)
  #   rescue Errno::ENOENT, Errno::ESRCH
  #   end
  # end
  #
  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  sleep 1
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

# This runs when we send unicorn a SIGUSR2 to do a hot restart. We need to
# clear out old BUNDLER_* and GEM_* environment variables, otherwise the new
# worker will still use the old Gemfile from the previous deployment, which
# will cause mysterious problems with libraries. BUNDLER_GEMFILE is the main
# thing we need to clear, but we wipe everything for safety.
#
# https://bogomips.org/unicorn/Sandbox.html
# https://jamielinux.com/blog/zero-downtime-unicorn-restart-when-using-rbenv/
before_exec do |server|
  ENV.keep_if { |name, value| name.match?(/\A(RAILS_.*|UNICORN_.*|HOME)\z/) }
  ENV["PATH"] = "#{ENV["HOME"]}/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
end
