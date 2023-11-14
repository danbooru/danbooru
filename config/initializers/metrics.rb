# frozen_string_literal: true

Rails.application.config.after_initialize do
  ApplicationMetrics.capture_rails_metrics!
end
