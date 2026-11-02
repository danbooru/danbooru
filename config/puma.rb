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
# * PUMA_CHECK_INTERVAL
# * PUMA_MAX_KEEP_ALIVE
# * PUMA_PERSISTENT_TIMEOUT
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

# The Rails environment the app will run in. Defaults to development.
rails_env = ENV.fetch("RAILS_ENV", "development")

# The server port or listening address. Default is http://0.0.0.0:3000.
if ENV.key?("PUMA_PORT")
  port ENV["PUMA_PORT"]
elsif ENV.key?("PUMA_BIND")
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
if ENV.key?("PUMA_WORKERS")
  workers ENV["PUMA_WORKERS"]
elsif rails_env == "development"
  # Use single worker mode in development for easier debugging
  workers 0
else
  # Default to one worker process per CPU core in production
  workers :auto
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

# The maximum number of requests to process in a keep alive connection before closing it.
max_keep_alive ENV.fetch("PUMA_MAX_KEEP_ALIVE", 1000).to_i

# The number of seconds to wait for another request within a persistent (keep alive) session.
persistent_timeout ENV.fetch("PUMA_PERSISTENT_TIMEOUT", 65).to_i

# The maximum number of seconds to wait for the first byte of the request
first_data_timeout 10

# The `environment` that Puma will run in.
environment rails_env

# The `pidfile` that Puma will use.
pidfile ENV.fetch("PUMA_PIDFILE", "tmp/pids/server.pid")

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Set Rack-level limits on requests. These limits come after any limits set by any proxies (Nginx or Cloudflare) in front of us.
#
# Cloudflare max URL length: 16KB (https://developers.cloudflare.com/fundamentals/reference/connection-limits/)
# Nginx max request line length: 8kb (`large_client_header_buffers 4 8k`, https://nginx.org/en/docs/http/ngx_http_core_module.html#large_client_header_buffers)
# Puma max URL length: 12kb (PUMA_REQUEST_URI_MAX_LENGTH fixed constant)
# Effective max URL length: 8kb
#
# Cloudflare max total header length: 128KB (https://developers.cloudflare.com/fundamentals/reference/connection-limits/)
# Nginx max total header count: 1000 (https://nginx.org/en/docs/http/ngx_http_core_module.html#max_headers)
# Nginx max total header length: 32kb (`large_client_header_buffers 4 8k`, https://nginx.org/en/docs/http/ngx_http_core_module.html#large_client_header_buffers)
# Puma max total header length: 112kb (MAX_HEADER fixed constant)
# Puma max single header length: 256 bytes per key / 80kb per value (fixed constants)
# Effective max header length: 1000 lines / 8kb per line / 32kb total header length
#
# Cloudflare max body length: 100MB
# Nginx max body length: 100MB (`client_max_body_size`, https://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size)
# Puma max body length: 100MB (`http_content_length_limit` below)
# Effective max body length: 100MB

# The maximum size of a request body in bytes (and hence, the max size of file uploads). If you change this, you must
# also change `client_max_body_size` in nginx.conf. Default: 100 MB.
# https://puma.io/puma/Puma/DSL.html#http_content_length_limit-instance_method
http_content_length_limit ENV.fetch("DANBOORU_MAX_FILE_SIZE", 100 * 1024 * 1024).to_i

# The maximum length of the query string in the URL (e.g. `?foo=bar`) and in application/x-www-form-urlencoded form bodies. Default: 1 MB.
# The URL length is already limited by Puma/Nginx/Cloudflare, so this effectively just limits the form body size.
# https://rack.github.io/rack/main/index.html#rackqueryparserbytesizelimit
ENV["RACK_QUERY_PARSER_BYTESIZE_LIMIT"] ||= "1048576"

# The maximum number of parameters in the query string and in application/x-www-form-urlencoded form bodies. Default: 512.
# Rails parses query strings (see config/initializers/query_parser_limits.rb), so this just limits the number of
# parameters in form bodies.
# https://rack.github.io/rack/main/index.html#rackqueryparserparamslimit
ENV["RACK_QUERY_PARSER_PARAMS_LIMIT"] ||= "512"

# The maximum total length of a multipart form, including files. Default: 100 MB.
ENV["RACK_MULTIPART_PARSER_BYTESIZE_LIMIT"] ||= ENV.fetch("DANBOORU_MAX_FILE_SIZE", 100 * 1024 * 1024).to_s

# The maximum total length of all non-file parameters in a multipart form. Default: 1 MB.
# https://rack.github.io/rack/main/index.html#rackmultipartbuffereduploadbytesizelimit
ENV["RACK_MULTIPART_BUFFERED_UPLOAD_BYTESIZE_LIMIT"] ||= "1048576"

# The maximum amount of nesting allowed in parameters (e.g. `a[b][c][d]=1`). Default: 32.
# https://rack.github.io/rack/main/index.html#paramdepthlimit
Rack::Utils.param_depth_limit = ENV.fetch("RACK_PARAM_DEPTH_LIMIT", 32).to_i + 1

# The maximum number of files a multipart form can contain. Default: 100.
# If you change this, you may also need to change MAX_FILES_PER_UPLOAD in app/models/upload.rb.
# https://rack.github.io/rack/main/index.html#multipartfilelimit
Rack::Utils.multipart_file_limit = ENV.fetch("RACK_MULTIPART_FILE_LIMIT", 100).to_i + 1

# The maximum number of form fields (including files) a multipart form can contain. Default: 512.
# https://rack.github.io/rack/main/index.html#multiparttotalpartlimit
Rack::Utils.multipart_total_part_limit = ENV.fetch("RACK_MULTIPART_TOTAL_PART_LIMIT", 512).to_i + 1

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
lowlevel_error_handler do |exception, _env|
  ApplicationMetrics[:puma_exceptions_total][exception: exception.class.name].increment

  backtrace = Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
  message = <<~EOS
    An unexpected error has occurred.

    Details: #{exception.class} exception raised.

    #{backtrace}
  EOS

  [500, {}, [message]]
rescue Exception => second_exception # This should never happen
  message = <<~EOS
    An unexpected error has occurred on the error page. Oh baby, a triple fault!

    Details: #{exception.class} exception raised.
    #{exception.backtrace.join("\n")}

    #{second_exception.class} exception raised.
    #{second_exception.backtrace.join("\n")}
  EOS

  [500, {}, [message]]
end

# https://github.com/schneems/puma_worker_killer
# https://docs.gitlab.com/ee/administration/operations/puma.html#puma-worker-killer
before_fork do
  require "puma_worker_killer"

  PumaWorkerKiller.rolling_restart_splay_seconds = 0.0..180.0 # 0 to 3 minutes in seconds
  PumaWorkerKiller.enable_rolling_restart ENV.fetch("PUMA_RESTART_INTERVAL", 2 * 60 * 60).to_i # every 2 hours by default
end

# This is called in the master process right before a worker is started.
before_worker_fork do |worker_id|
  ApplicationMetrics[:puma_restarts_total][worker: worker_id].increment
end

# This is called every time a worker process starts or restarts. It's not called in single mode (when workers == 0)
# when there are no child worker processes.
before_worker_boot do |worker_id|
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
