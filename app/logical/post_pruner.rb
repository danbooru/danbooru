module PostPruner
  module_function

  def prune!
    prune_pending!
    prune_flagged!
    prune_appealed!
  end

  def prune_pending!
    Post.pending.expired.each do |post|
      post.delete!("Unapproved in three days", user: User.system)
    end
  end

  def prune_flagged!
    PostFlag.expired.each do |flag|
      flag.post.delete!("Unapproved in three days after returning to moderation queue", user: User.system)
    end
  end

  def prune_appealed!
    PostAppeal.expired.each do |appeal|
      appeal.post.delete!("Unapproved in three days after returning to moderation queue", user: User.system)
    end
  end
end
