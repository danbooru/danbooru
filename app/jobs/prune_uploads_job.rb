# frozen_string_literal: true

# A job that runs hourly to delete all completed, stale, or failed uploads.
# Spawned by {DanbooruMaintenance}.
class PruneUploadsJob < ApplicationJob
  def perform
    Upload.prune!
  end
end
