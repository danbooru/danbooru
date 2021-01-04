# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

if defined?(Unicorn) && Rails.env.production?
  # Unicorn self-process killer
  require 'unicorn/worker_killer'

  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, 5_000, 10_000

  # Max memory size (RSS) per worker
  # use Unicorn::WorkerKiller::Oom, (192*(1024**2)), (256*(1024**2))
end

run Rails.application
Rails.application.load_server
