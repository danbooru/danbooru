# frozen_string_literal: true

class ProcessUploadJob < ApplicationJob
  queue_with_priority -20

  def job_timeout
    10.minutes
  end

  def perform(upload)
    upload.process_upload!
  end
end
