module DanbooruMaintenance
  module_function

  def hourly
  end

  def daily
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    PostPruner.new.prune!
    Upload.prune!
    Delayed::Job.where('created_at < ?', 45.days.ago).delete_all
    PostDisapproval.prune!
    ForumSubscription.process_all!
    PostDisapproval.dmail_messages!
    regenerate_post_counts!
    SuperVoter.init!
    TokenBucket.prune!
    TagChangeRequestPruner.warn_all
    TagChangeRequestPruner.reject_all
    Ban.prune!
    CuratedPoolUpdater.update_pool!

    ActiveRecord::Base.connection.execute("vacuum analyze") unless Rails.env.test?
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

  def regenerate_post_counts!
    updated_tags = Tag.regenerate_post_counts!
    updated_tags.each do |tag|
      DanbooruLogger.info("Updated tag count", tag.attributes)
    end
  end

  def rescue_exception(exception)
    DanbooruLogger.log(exception)
    raise exception
  end
end
