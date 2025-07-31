# frozen_string_literal: true

# A component for uploading files to Danbooru. Used on the /uploads/new page.
class FileUploadComponent < ApplicationComponent
  attr_reader :url, :referer_url, :drop_target, :max_file_size, :max_files_per_upload

  delegate :simple_form_for, to: :helpers

  # @param url [String] Optional. The URL to upload. If present, the URL field
  #   will be prefilled in the widget and the upload will be immediately triggered.
  # @param referer_url [String] Optional. The referrer URL passed by the bookmarklet.
  # @param drop_target [String] A CSS selector. The target for drag and drop
  #   events. If "body", then files can be dropped anywhere on the page, not
  #   just on the upload widget itself.
  # @param max_file_size [Integer] The max size in bytes of an upload.
  # @param max_files_per_upload [Integer] The maximum number of files per upload.
  def initialize(url: nil, referer_url: nil, drop_target: nil, max_file_size: Danbooru.config.max_file_size, max_files_per_upload: Upload::MAX_FILES_PER_UPLOAD)
    @url = url
    @referer_url = referer_url
    @drop_target = drop_target
    @max_file_size = max_file_size
    @max_files_per_upload = max_files_per_upload
    super
  end
end
