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
        janitor_trial = JanitorTrial.where(user_id: user.id).first

        if janitor_trial
          janitor_trial.demote!
          unknown_level = nil
        else
          user.promote_to!(User::Levels::PLATINUM, :skip_dmail => true)
          unknown_level = "\n\nYour previous user level was unknown so your user level has defaulted to Platinum. If you feel this to be in error please reply to this message with your original level."
        end
 
        Dmail.create_split(
          :to_id => user.id,
          :title => "Janitor inactivity",
          :body => "You haven't approved a post in the past two months. In order to make sure the list of active janitors is up-to-date, you have lost your janitor privileges. Please reply to this message if you want to be reinstated.#{unknown_level}"
        )
      end
    end
  end
end
