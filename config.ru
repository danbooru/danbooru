# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

root_path = Rails.application.config.relative_url_root.presence || "/"
map root_path do
  run Rails.application
end

Rails.application.load_server
