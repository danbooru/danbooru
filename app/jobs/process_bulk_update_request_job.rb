# A job that applies a bulk update request after it is approved.
#
# @see {BulkUpdateRequestProcessor}
# @see {BulkUpdateRequest}
class ProcessBulkUpdateRequestJob < ApplicationJob
  retry_on Exception, attempts: 0

  def perform(bulk_update_request)
    bulk_update_request.processor.process!
  end
end
