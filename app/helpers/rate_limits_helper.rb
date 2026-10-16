# frozen_string_literal: true

module RateLimitsHelper
  # Format a points-per-second refill rate as a human-readable string, picking
  # the most natural time unit (per hour if under 1/minute, otherwise per minute).
  def humanize_rate(rate)
    per_minute = rate * 60
    if per_minute < 1
      "#{(rate * 3600).round} per hour"
    else
      "#{per_minute.round} per minute"
    end
  end
end
