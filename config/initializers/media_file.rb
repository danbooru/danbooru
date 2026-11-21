# frozen_string_literal: true

# Configure the media_file library in lib/media-file, which reads, validates, and resizes uploads.
MediaFile.configure do |config|
  config.logger = Rails.logger
  config.sandbox = !Danbooru.config.disable_upload_sandbox?.to_s.truthy?
  config.max_file_size = Danbooru.config.max_file_size.to_i
  config.max_image_resolution = Danbooru.config.max_image_resolution
  config.max_image_width = Danbooru.config.max_image_width
  config.max_image_height = Danbooru.config.max_image_height
  config.max_concurrency = Danbooru.config.max_concurrency.to_i
end
