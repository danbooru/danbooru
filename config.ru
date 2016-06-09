# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if defined?(Unicorn) && Rails.env.production?
  require_dependency 'gctools/oobgc'
  use GC::OOB::UnicornMiddleware
end

run Rails.application
