# frozen_string_literal: true

# A job that applies a bulk update request after it is approved.
#
# @see {BulkUpdateRequestProcessor}
# @see {BulkUpdateRequest}
class ProcessBulkUpdateRequestJob < ApplicationJob
  def perform(bulk_update_request)
    bulk_update_request.processor.process!
  end
end
