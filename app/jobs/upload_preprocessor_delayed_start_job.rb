# A job that downloads and generates thumbnails in the background for an image
# uploaded with the upload bookmarklet.
class UploadPreprocessorDelayedStartJob < ApplicationJob
  queue_as :default
  queue_with_priority(-1)

  def perform(source, referer_url, uploader)
    UploadService::Preprocessor.new(source: source, referer_url: referer_url).delayed_start(uploader)
  end
end
