# frozen_string_literal: true

module DanbooruMaintenance
  module_function

  def hourly
    queue PrunePostsJob
    queue PruneRateLimitsJob
    queue RegeneratePostCountsJob
    queue PruneUploadsJob
    queue PruneJobsJob
    queue PruneBansJob
    #queue AmcheckDatabaseJob
  end

  def daily
    queue PrunePostDisapprovalsJob
    queue PruneBulkUpdateRequestsJob
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
    Rails.logger.level = :info if !Rails.env.local?
    DanbooruLogger.info("Queueing #{job.name}")
    ApplicationRecord.connection.verify!
    job.perform_later
  rescue Exception => e # rubocop:disable Lint/RescueException
    DanbooruLogger.log(e)
    raise e if Rails.env.test?
  end
end
