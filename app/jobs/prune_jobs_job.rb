# frozen_string_literal: true

# A job that runs daily to delete all stale jobs. Spawned by {DanbooruMaintenance}.
class PruneJobsJob < ApplicationJob
  def perform
    GoodJob::ActiveJobJob.where("created_at < ?", 7.days.ago).destroy_all
  end
end
