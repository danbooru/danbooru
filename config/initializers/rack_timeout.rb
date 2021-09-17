# https://github.com/sharpstone/rack-timeout#configuring
options = {
  service_timeout: ENV.fetch("RACK_REQUEST_TIMEOUT", 65).to_i,
  wait_timeout: false,
  wait_overtime: false,
  service_past_wait: false,
  term_on_timeout: false
}

Rack::Timeout::Logger.logger = Rails.logger.dup
Rack::Timeout::Logger.logger.level = :error

Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, **options
