class DailyMaintenance
  def run
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    PostPruner.new.prune!
    TagPruner.new.prune!
    Upload.delete_all(['created_at < ?', 1.day.ago])
    ModAction.delete_all(['created_at < ?', 30.days.ago])
    Delayed::Job.delete_all(['created_at < ?', 7.days.ago])
    PostVote.prune!
    CommentVote.prune!
    ApiCacheGenerator.new.generate_tag_cache
    PostDisapproval.prune!
    ForumSubscription.process_all!
    TagAlias.update_cached_post_counts_for_all
    PostDisapproval.dmail_messages!
    Tag.clean_up_negative_post_counts!
    PostApproval.prune!
    SuperVoter.init!
    TokenBucket.prune!
  end
end
