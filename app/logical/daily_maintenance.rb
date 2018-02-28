class DailyMaintenance
  def run
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    PostPruner.new.prune!
    TagPruner.new.prune!
    Upload.delete_all(['created_at < ?', 1.day.ago])
    Delayed::Job.delete_all(['created_at < ?', 45.days.ago])
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
  end
end
