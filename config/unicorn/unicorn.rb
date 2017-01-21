require "dotenv"

rails_env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
Dotenv.load(".env.local", ".env.#{rails_env}", ".env")

addr = ENV["UNICORN_LISTEN"] || "127.0.0.1:9000"
app_path = ENV["UNICORN_ROOT"] || Dir.pwd
instance = "unicorn-#{addr}"

listen addr
worker_processes ENV["UNICORN_PROCESSES"].to_i || 1
timeout ENV["UNICORN_TIMEOUT"].to_i || 90

user = ENV["UNICORN_USER"] || "danbooru"
group = ENV["UNICORN_GROUP"] || "danbooru"

stderr_path ENV["UNICORN_LOG"] || "log/#{instance}.log"
stdout_path ENV["UNICORN_LOG"] || "log/#{instance}.log"

working_directory app_path
pid ENV["UNICORN_PIDFILE"] || "#{app_path}/tmp/pids/#{instance}.pid"

if rails_env == "production"
  preload_app true

  before_fork do |server, worker|
    ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

    # Throttle the master from forking too quickly by sleeping.  Due
    # to the implementation of standard Unix signal handlers, this
    # helps (but does not completely) prevent identical, repeated signals
    # from being lost when the receiving process is busy.
    sleep 1
  end

  after_fork do |server, worker|
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  end
else
  preload_app false
end
