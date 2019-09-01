module DanbooruMaintenance
  module_function

  def hourly
    UploadErrorChecker.new.check!
  rescue Exception => exception
    rescue_exception(exception)
  end

  def daily
    PostPruner.new.prune!
    Upload.prune!
    Delayed::Job.where('created_at < ?', 45.days.ago).delete_all
    PostDisapproval.prune!
    ForumSubscription.process_all!
    TagAlias.update_cached_post_counts_for_all
    PostDisapproval.dmail_messages!
    Tag.clean_up_negative_post_counts!
    SuperVoter.init!
    TokenBucket.prune!
    TagChangeRequestPruner.warn_all
    TagChangeRequestPruner.reject_all
    Ban.prune!

    ApplicationRecord.without_timeout do
      ActiveRecord::Base.connection.execute("vacuum analyze") unless Rails.env.test?
    end
  rescue Exception => exception
    rescue_exception(exception)
  end

  def weekly
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    UserPasswordResetNonce.prune!
    ApproverPruner.prune!
    TagRelationshipRetirementService.find_and_retire!
  rescue Exception => exception
    rescue_exception(exception)
  end

  def rescue_exception(exception)
    DanbooruLogger.log(exception)
    raise exception
  end
end
