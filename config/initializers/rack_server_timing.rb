# frozen_string_literal: true

require_relative "../../app/logical/rack_server_timing"
Rails.application.config.middleware.insert_before 0, RackServerTiming
Rails.application.config.middleware.delete Rack::Runtime
