# frozen_string_literal: true

# A job that runs hourly to mark as failed all uploads that got stuck in the 'processing' state for more than 4 hours.
# Spawned by {DanbooruMaintenance}.
class PruneUploadsJob < ApplicationJob
  def perform
    MediaAsset.prune!
    UploadMediaAsset.prune!
    Upload.prune!
  end
end
