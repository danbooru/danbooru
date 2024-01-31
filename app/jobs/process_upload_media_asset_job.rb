# frozen_string_literal: true

class ProcessUploadMediaAssetJob < ApplicationJob
  queue_with_priority -10

  def job_timeout
    10.minutes
  end

  def perform(upload_media_asset)
    upload_media_asset.process_upload!
  rescue Exception => e
    # This should never happen. It will only happen if `process_upload!` raises an unexpected exception inside its own exception handler.
    upload_media_asset.update!(status: :failed, error: e.message)
    raise
  end
end
