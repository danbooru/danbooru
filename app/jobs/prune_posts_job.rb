# frozen_string_literal: true

# A job that runs hourly to delete all expired pending, flagged, and appealed
# posts. Spawned by {DanbooruMaintenance}.
class PrunePostsJob < ApplicationJob
  def perform
    PostPruner.prune!
  end
end
