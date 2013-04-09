class PostPruner
  attr_reader :admin

  def initialize
    @admin = User.where(:level => User::Levels::ADMIN).first
  end

  def prune!
    Post.without_timeout do
      prune_pending!
      prune_flagged!
      prune_mod_actions!
    end
  end

protected

  def prune_pending!
    CurrentUser.scoped(admin, "127.0.0.1") do
      Post.where("is_deleted = ? and is_pending = ? and created_at < ?", false, true, 3.days.ago).each do |post|
        begin
          post.flag!("Unapproved in three days")
        rescue PostFlag::Error
          # swallow
        end
        post.delete!
      end
    end
  end

  def prune_flagged!
    CurrentUser.scoped(admin, "127.0.0.1") do
      Post.where("is_deleted = ? and is_flagged = ?", false, true).each do |post|
        if post.flags.unresolved.old.any?
          begin
            post.flag!("Unapproved in three days after returning to moderation queue")
          rescue PostFlag::Error
            # swallow
          end
          post.delete!
        end
      end
    end
  end

  def prune_mod_actions!
    ModAction.destroy_all(["creator_id = ? and description like ?", admin.id, "deleted post %"])
  end
end
