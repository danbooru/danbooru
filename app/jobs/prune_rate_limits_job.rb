# frozen_string_literal: true

# A job that runs hourly to delete all state rate limit objects from the
# database. Spawned by {DanbooruMaintenance}.
class PruneRateLimitsJob < ApplicationJob
  def perform
    RateLimit.prune!
  end
end
