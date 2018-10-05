class DailyMaintenance
  def hourly
    sm = Danbooru.config.storage_manager
    Post.where("id >= ? and created_at > ?", 3275713, 1.day.ago).find_each do |post|
      if HTTParty.head("https://sonohara.donmai.us/data/#{post.md5}.#{post.file_ext}").code == 404
        puts ["o", post.id, post.md5].inspect
        UploadService::Utils.distribute_files File.open(sm.file_path(post, post.file_ext, :original), "rb"), post, :original
      end

      if post.has_preview? && HTTParty.head("https://sonohara.donmai.us/data/preview/#{post.md5}.jpg").code == 404
        puts ["p", post.id, post.md5].inspect
        UploadService::Utils.distribute_files File.open(sm.file_path(post, post.file_ext, :preview), "rb"), post, :preview
      end

      if post.has_large? && HTTParty.head("https://sonohara.donmai.us/data/sample/sample-#{post.md5}.jpg").code == 404
        puts ["l", post.id, post.md5].inspect
        UploadService::Utils.distribute_files File.open(sm.file_path(post, post.file_ext, :large), "rb"), post, :large
      end
    end
  end

  def run
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
  end
end
