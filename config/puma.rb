# This file contains configuration settings for the Puma web server. These
# settings apply when running Danbooru with `bin/rails server`.
#
# The following environment variables are used:
#
# * RAILS_ENV
# * PUMA_PORT
# * PUMA_BIND
# * PUMA_WORKERS
# * PUMA_MIN_THREADS
# * PUMA_MAX_THREADS
# * PUMA_WORKER_TIMEOUT
# * PUMA_PIDFILE
# * PUMA_CONTROL_URL
# * PUMA_METRICS_URL
#
# Use `bin/pumactl` to control a running Puma instance.
#
# @see https://puma.io
# @see https://github.com/puma/puma
# @see https://github.com/puma/puma/blob/319f84db13ee59f7b24885cec686d5c714998a4c/lib/puma/configuration.rb#L188 (default options)
# @see https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

# The server port or listening address. Default is http://0.0.0.0:3000.
if ENV.has_key?("PUMA_PORT")
  port ENV["PUMA_PORT"]
elsif ENV.has_key?("PUMA_BIND")
  bind ENV["PUMA_BIND"]
else
  # low_latency=true means TCP_NODELAY
  # backlog=1024 means socket listen backlog
  # https://github.com/puma/puma/blob/319f84db13ee59f7b24885cec686d5c714998a4c/lib/puma/dsl.rb#L193
  bind "tcp://0.0.0.0:3000?low_latency=true&backlog=1024"
end

# The number of `workers` to boot in clustered mode. Workers are forked web
# server processes. If using threads and workers together, the concurrency of
# the application would be max `threads` * `workers`. Workers do not work on
# JRuby or Windows (both of which do not support processes). The Postgres
# connection limit may need to be raised for high `thread` * `worker` counts.
if ENV.has_key?("PUMA_WORKERS")
  workers ENV["PUMA_WORKERS"]
elsif ENV["RAILS_ENV"] == "production"
  workers ENV.fetch("PUMA_WORKERS", Etc.nprocessors)
else
  # Use single worker mode in development for easier debugging
  workers 0
end

# The number of threads per worker to use. The `threads` method
# setting takes two numbers: a minimum and maximum. Any libraries that use
# thread pools should be configured to match the maximum value specified for
# Puma.
max_threads_count = ENV.fetch("PUMA_MAX_THREADS", 5)
min_threads_count = ENV.fetch("PUMA_MIN_THREADS", 1)
threads min_threads_count, max_threads_count

# Verifies that all workers have checked in to the master process within
# the given timeout. If not the worker process will be restarted. This is
# not a request timeout, it is to protect against a hung or dead process.
# Setting this value will not protect against slow requests.
worker_timeout ENV.fetch("PUMA_WORKER_TIMEOUT", 60)

# The number of seconds to wait for another request within a persistent (keep
# alive) session.
persistent_timeout 20

# The number of seconds to wait until we get the first data for the request
first_data_timeout 30

# The `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV", "development")

# The `pidfile` that Puma will use.
pidfile ENV.fetch("PUMA_PIDFILE", "tmp/pids/server.pid")

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
if ENV["RAILS_ENV"] == "production"
  preload_app!
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Enable Prometheus metrics.
# https://github.com/harmjanblok/puma-metrics
plugin :metrics

# Export Prometheus metrics by default on http://localhost:9393
metrics_url ENV.fetch("PUMA_METRICS_URL", "tcp://localhost:9393")

# Start the Puma control rack application on +url+. This application can
# be communicated with to control the main server. Additionally, you can
# provide an authentication token, so all requests to the control server
# will need to include that token as a query parameter. This allows for
# simple authentication.
#
# Usage:
#
# * bin/pumactl stats
# * bin/pumactl -C tcp://localhost:9293 stats
#
# https://github.com/puma/puma#controlstatus-server
activate_control_app ENV.fetch("PUMA_CONTROL_URL", "tcp://localhost:9293"), no_token: true
