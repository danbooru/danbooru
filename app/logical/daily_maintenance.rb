class DailyMaintenance
  def hourly
    sm = Danbooru.config.storage_manager
    Post.where("id >= ? and created_at > ?", 3275713, 10.minutes.ago).find_each do |post|
      file_path = sm.file_path(post, post.file_ext, :original)
      sm.store_file(File.open(file_path, "rb"), post, :original)
      preview_path = sm.file_path(post, post.file_ext, :preview)
      sm.store_file(File.open(preview_path, "rb"), post, :preview)
      if post.has_large?
        sample_path = sm.file_path(post, post.file_ext, :large)
        sm.store_file(File.open(sample_path, "rb"), post, :large)
      end
    end
  end

  def run
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    PostPruner.new.prune!
    TagPruner.new.prune!
    Upload.where('created_at < ?', 1.day.ago).delete_all
    Delayed::Job.where('created_at < ?', 45.days.ago).delete_all
    #ForumPostVote.where("created_at < ?", 90.days.ago).delete_all
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
  end
end
