# frozen_string_literal: true

# A job that runs daily to delete all stale delayed jobs. Spawned by
# {DanbooruMaintenance}.
class PruneDelayedJobsJob < ApplicationJob
  def perform
    Delayed::Job.where("created_at < ?", 45.days.ago).delete_all
  end
end
