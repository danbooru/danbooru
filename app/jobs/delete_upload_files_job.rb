class DeleteUploadFilesJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(md5, file_ext, upload_id)
    UploadService::Utils.delete_file(md5, file_ext, upload_id)
  end
end
