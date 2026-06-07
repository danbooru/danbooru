# frozen_string_literal: true

# A job that runs daily to reject expired bulk update requests. Spawned by
# {DanbooruMaintenance}.
class PruneBulkUpdateRequestsJob < ApplicationJob
  def perform
    BulkUpdateRequest::Pruner.warn_old
    BulkUpdateRequest::Pruner.reject_expired
  end
end
