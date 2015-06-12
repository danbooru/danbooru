class JanitorPruner
  def inactive_janitors
    User.where("level = ?", User::Levels::JANITOR).select do |user|
      approval_count = Post.where("created_at >= ? and approver_id = ?", 2.months.ago, user.id).count
      approval_count == 0
    end
  end

  def prune!
    admin = User.admins.first

    inactive_janitors.each do |user|
      CurrentUser.scoped(admin, "127.0.0.1") do
        Dmail.create_split(
          :to_id => user.id,
          :title => "Janitor inactivity",
          :body => "You haven't approved a post in the past two months. In order to make sure the list of active janitors is up-to-date, you have lost your janitor privileges. Please reply to this message if you want to be reinstated."
        )

        janitor_trial = JanitorTrial.where(user_id: user.id).first
        if janitor_trial
          user.promote_to!(janitor_trial.original_level, :skip_feedback => true)
        else
          user.promote_to!(User::Levels::GOLD, :skip_feedback => true)
        end
      end
    end
  end
end
