module CuratedPoolUpdater
  def self.curated_posts(date_range: (1.week.ago..Time.now), limit: 100)
    posts = Post.where(created_at: date_range)
    posts = posts.joins(:votes).where("post_votes.score": SuperVoter::MAGNITUDE)
    posts = Post.where(id: posts.group(:id).order(Arel.sql("COUNT(*) DESC")).limit(limit))
    posts
  end

  def self.update_pool!(pool_id = Danbooru.config.curated_pool_id)
    return unless pool_id.present?

    CurrentUser.scoped(User.system, "127.0.0.1") do
      Pool.find(pool_id).update!(post_ids: curated_posts.pluck(:id))
    end
  end
end
