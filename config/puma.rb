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
# * PUMA_RESTART_INTERVAL
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
  require "concurrent-ruby"
  workers Concurrent.available_processor_count.to_i.clamp(1..)
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

# How often worker processes check in with the master process. This also controls how often worker metrics are updated in the master process.
# Default: once per second.
worker_check_interval ENV.fetch("PUMA_CHECK_INTERVAL", 1).to_i

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

# The last resort error handler for exceptions unhandled by the app. This only handles errors not handled by the
# `rescue_exception` handler in ApplicationController. This normally only happens if `rescue_exception` itself raises an
# error, or if a middleware raises an error before or after the request is handled by the app.
#
# When RAILS_ENV is development, errors will be swallowed by the BetterErrors gem before they get to this point.
lowlevel_error_handler do |exception, env|
  ApplicationMetrics[:puma_exceptions_total][exception: exception.class.name].increment

  backtrace = Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
  message = <<~EOS
    An unexpected error has occurred.

    Details: #{exception.class.to_s} exception raised.

    #{backtrace}
  EOS

  [500, {}, [message]]
rescue Exception => second_exception # This should never happen
  message = <<~EOS
    An unexpected error has occurred on the error page. Oh baby, a triple fault!

    Details: #{exception.class.to_s} exception raised.
    #{exception.backtrace.join("\n")}

    #{second_exception.class.to_s} exception raised.
    #{second_exception.backtrace.join("\n")}
  EOS

  [500, {}, [message]]
end

# https://github.com/schneems/puma_worker_killer
# https://docs.gitlab.com/ee/administration/operations/puma.html#puma-worker-killer
before_fork do
  require 'puma_worker_killer'

  PumaWorkerKiller.rolling_restart_splay_seconds = 0.0..180.0 # 0 to 3 minutes in seconds
  PumaWorkerKiller.enable_rolling_restart ENV.fetch("PUMA_RESTART_INTERVAL", 2 * 60 * 60).to_i # every 2 hours by default
end

# This is called in the master process right before a worker is started.
on_worker_fork do |worker_id|
  ApplicationMetrics[:puma_restarts_total][worker: worker_id].increment
end

# This is called every time a worker process starts or restarts. It's not called in single mode (when workers == 0)
# when there are no child worker processes.
on_worker_boot do |worker_id|
  # Starts a background thread that serves process metrics on a Unix domain socket under tmp/.
  require_relative "../app/logical/application_metrics"
  ApplicationMetrics.puma_worker_id = worker_id.to_s
  ApplicationMetrics.reset_metrics # Don't inherit metrics from the master process
  ApplicationMetrics.serve_process_metrics
end

# Initialize metrics in the master process when running in cluster mode (when workers > 0), or in the main process when
# running in single mode (when workers == 0)
require_relative "../app/logical/application_metrics"
ApplicationMetrics.puma_worker_id = "master" if @options[:workers] > 0
ApplicationMetrics.serve_process_metrics
