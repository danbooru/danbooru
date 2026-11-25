# frozen_string_literal: true

# A job that applies a bulk update request after it is approved.
#
# @see {BulkUpdateRequest::Processor}
# @see {BulkUpdateRequest}
class ProcessBulkUpdateRequestJob < ApplicationJob
  # @param bulk_update_request [BulkUpdateRequest] the BUR to process. A queued BUR is skipped if it was approved again
  #   after this job was queued, since the later approval's job will process it.
  def perform(bulk_update_request:)
    approved_at = bulk_update_request.with_lock do
      case bulk_update_request.status
      when "processing"
        bulk_update_request.updated_at
      when "queued"
        next if bulk_update_request.updated_at > enqueued_at

        updated_at = bulk_update_request.updated_at
        bulk_update_request.update!(status: "processing")
        updated_at
      end
    end

    bulk_update_request.processor.process!(approved_at:) if approved_at.present?
  end
end
