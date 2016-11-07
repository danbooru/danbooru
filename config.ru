# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if defined?(Unicorn) && Rails.env.production?
  # Unicorn self-process killer
  require 'unicorn/worker_killer'

  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, 5_000, 10_000

  # Max memory size (RSS) per worker
  #use Unicorn::WorkerKiller::Oom, (192*(1024**2)), (256*(1024**2))

  require 'gctools/oobgc'
  use GC::OOB::UnicornMiddleware
end

run Rails.application
