# frozen_string_literal: true

require_relative "../../app/logical/read_only_mode_middleware"

Rails.application.config.middleware.insert_before 0, ReadOnlyModeMiddleware
