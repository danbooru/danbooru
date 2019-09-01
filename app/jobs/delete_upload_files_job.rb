class DeleteUploadFilesJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(md5, file_ext, upload_id)
    # do nothing
  end
end
