# A job that deletes a post's files after it's replaced, or a preprocessed
# upload is never completed.
class DeletePostFilesJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(id, md5, file_ext)
    Post.delete_files(id, md5, file_ext)
  end
end
