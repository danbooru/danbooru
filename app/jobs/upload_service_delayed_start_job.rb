class UploadServiceDelayedStartJob < ApplicationJob
  queue_as :default
  queue_with_priority -1

  def perform(uploader)
    UploadService.delayed_start(uploader.id)
  end
end
