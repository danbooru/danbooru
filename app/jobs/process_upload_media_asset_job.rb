# frozen_string_literal: true

class ProcessUploadMediaAssetJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency

  queue_with_priority -10

  # Limit how many files can be downloaded at once from sites with a `max_concurrent_downloads` limit. Waiting jobs are
  # retried when a running job finishes. Jobs for other sites don't get a label, so GoodJob ignores the rule for them.
  good_job_concurrency_rule(
    label: lambda do
      extractor = arguments.first.source_extractor
      "downloads:#{extractor.site_name}" if extractor&.max_concurrent_downloads.present?
    end,
    apply_label: true,
    perform_limit: -> { arguments.first.source_extractor.max_concurrent_downloads },
  )

  def job_timeout
    10.minutes
  end

  def perform(upload_media_asset)
    upload_media_asset.process_upload!
  rescue Exception => e
    # This should never happen. It will only happen if `process_upload!` raises an unexpected exception inside its own exception handler.
    upload_media_asset.update!(status: :failed, error: e.message)
    raise
  end
end
