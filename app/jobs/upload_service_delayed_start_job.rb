class UploadServiceDelayedStartJob < ApplicationJob
  queue_as :default
  queue_with_priority(-1)

  def perform(params, uploader)
    UploadService.new(params).delayed_start(uploader.id)
  end
end
