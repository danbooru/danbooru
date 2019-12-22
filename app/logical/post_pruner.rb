class PostPruner
  def prune!
    prune_pending!
    prune_flagged!
    prune_mod_actions!
  end

  protected

  def prune_pending!
    CurrentUser.scoped(User.system, "127.0.0.1") do
      Post.where("is_deleted = ? and is_pending = ? and created_at < ?", false, true, 3.days.ago).each do |post|
        post.delete!("Unapproved in three days")
      rescue PostFlag::Error
        # swallow
      end
    end
  end

  def prune_flagged!
    CurrentUser.scoped(User.system, "127.0.0.1") do
      Post.where("is_deleted = ? and is_flagged = ?", false, true).each do |post|
        if post.flags.unresolved.old.any?
          begin
            post.delete!("Unapproved in three days after returning to moderation queue")
          rescue PostFlag::Error
            # swallow
          end
        end
      end
    end
  end

  def prune_mod_actions!
    ModAction.where(["creator_id = ? and description like ?", User.system.id, "deleted post %"]).destroy_all
  end
end
