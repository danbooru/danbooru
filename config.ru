# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if defined? Unicorn
  require_dependency 'unicorn/oob_gc'
  GC.disable
  use Unicorn::OobGC
end

run Rails.application
