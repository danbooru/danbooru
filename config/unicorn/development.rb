# Set your full path to application.
app_path = "/var/www/danbooru2/current"

# Set unicorn options
worker_processes 2

preload_app false
timeout 180
listen "127.0.0.1:9000"

# Spawn unicorn master worker for user apps (group: apps)
user 'danbooru', 'danbooru'

# Fill path to your app
working_directory app_path

# Should be 'production' by default, otherwise use other env
rails_env = ENV['RAILS_ENV'] || 'production'

# Log everything to one file
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

# Set master PID location
pid "#{app_path}/tmp/pids/unicorn.pid"
