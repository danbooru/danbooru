module DanbooruMaintenance
  module_function

  def hourly
    queue PruneUploadsJob
    queue PrunePostsJob
    queue PruneRateLimitsJob
    queue RegeneratePostCountsJob
  end

  def daily
    queue PruneDelayedJobsJob
    queue PrunePostDisapprovalsJob
    queue PruneBulkUpdateRequestsJob
    queue PruneBansJob
    queue BigqueryExportAllJob
    queue VacuumDatabaseJob
  end

  def weekly
    queue RetireTagRelationshipsJob
    queue DmailInactiveApproversJob
  end

  def monthly
    queue PruneApproversJob
  end

  def queue(job)
    Rails.logger.level = :info
    DanbooruLogger.info("Queueing #{job.name}")
    job.perform_later
  rescue Exception => e # rubocop:disable Lint/RescueException
    DanbooruLogger.log(exception)
    raise e if Rails.env.test?
  end
end
