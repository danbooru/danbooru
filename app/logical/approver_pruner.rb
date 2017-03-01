class ApproverPruner
  def inactive_approvers
    User.where("bit_prefs & ? > 0", User.flag_value_for("can_approve_posts")).select do |user|
      approval_count = Post.where("created_at >= ? and approver_id = ?", 3.months.ago, user.id).count
      approval_count == 0
    end
  end

  def prune!
    inactive_approvers.each do |user|
      CurrentUser.scoped(User.system, "127.0.0.1") do
        next if user.is_admin?

        janitor_trial = JanitorTrial.where(user_id: user.id).first

        if janitor_trial && user.can_approve_posts?
          janitor_trial.demote!
        else
          user.can_approve_posts = false
          user.save
        end
 
        Dmail.create_automated(
          :to_id => user.id,
          :title => "Approver inactivity",
          :body => "You haven't approved a post in the past three months. In order to make sure the list of active approvers is up-to-date, you have lost your approver privileges."
        )
      end
    end
  end
end
