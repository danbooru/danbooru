# frozen_string_literal: true

require_relative "../../app/logical/read_only_mode"
require_relative "../../app/logical/read_only_mode_middleware"

Rails.application.config.middleware.insert_before 0, ReadOnlyModeMiddleware

Rails.application.config.after_initialize do
  next unless GoodJob::CLI.within_exe?

  if ReadOnlyMode.enabled?
    ReadOnlyMode.pause_jobs!
  else
    ReadOnlyMode.unpause_jobs!
  end
end
