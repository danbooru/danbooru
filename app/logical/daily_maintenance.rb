class DailyMaintenance
  def run
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    PostPruner.new.prune!
    TagPruner.new.prune!
    Upload.delete_all(['created_at < ?', 1.day.ago])
    ModAction.delete_all(['created_at < ?', 3.days.ago])
    Delayed::Job.delete_all(['created_at < ?', 7.days.ago])
    PostVote.delete_all(['created_at < ?', 1.month.ago])
    CommentVote.delete_all(['created_at < ?', 1.month.ago])
    # UserUploadClamper.new.clamp_all!
    TagSubscription.process_all
    ApiCacheGenerator.new.generate_tag_cache
    ForumSubscription.process_all!
  end
end
