# frozen_string_literal: true

# A job that runs daily to reject expired bulk update requests. Spawned by
# {DanbooruMaintenance}.
class PruneBulkUpdateRequestsJob < ApplicationJob
  def perform
    BulkUpdateRequestPruner.warn_old
    BulkUpdateRequestPruner.reject_expired
  end
end
