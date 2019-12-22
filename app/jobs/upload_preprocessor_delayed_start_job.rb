class UploadPreprocessorDelayedStartJob < ApplicationJob
  queue_as :default
  queue_with_priority(-1)

  def perform(source, referer_url, uploader)
    UploadService::Preprocessor.new(source: source, referer_url: referer_url).delayed_start(uploader.id)
  end
end
