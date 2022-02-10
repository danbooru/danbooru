# frozen_string_literal: true

class ProcessUploadMediaAssetJob < ApplicationJob
  queue_with_priority -1

  def perform(upload_media_asset)
    upload_media_asset.process_upload!
  end
end
