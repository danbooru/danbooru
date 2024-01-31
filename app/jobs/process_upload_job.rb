# frozen_string_literal: true

class ProcessUploadJob < ApplicationJob
  queue_with_priority -20

  def perform(upload)
    upload.process_upload!
  end
end
