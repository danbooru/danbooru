module Maintenance
  module_function

  def hourly
    UploadErrorChecker.new.check!
    DelayedJobErrorChecker.new.check!
  rescue Exception => exception
    rescue_exception(exception)
  end

  def daily
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    PostPruner.new.prune!
    Upload.where('created_at < ?', 1.day.ago).delete_all
    Delayed::Job.where('created_at < ?', 45.days.ago).delete_all
    PostVote.prune!
    CommentVote.prune!
    ApiCacheGenerator.new.generate_tag_cache
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
    backtrace = Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
    Rails.logger.error("#{exception.class}: #{exception.message}\n#{backtrace}")

    if defined?(NewRelic::Agent)
      NewRelic::Agent.notice_error(exception, custom_params: { backtrace: backtrace })
    end

    raise exception
  end
end
