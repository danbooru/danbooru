class PostPruner
  def prune!
    prune_pending!
    prune_flagged!
  end

  def prune_pending!
    Post.pending.expired.each do |post|
      post.delete!("Unapproved in three days", user: User.system)
    end
  end

  def prune_flagged!
    Post.flagged.each do |post|
      if post.flags.unresolved.old.any?
        post.delete!("Unapproved in three days after returning to moderation queue", user: User.system)
      end
    end
  end
end
