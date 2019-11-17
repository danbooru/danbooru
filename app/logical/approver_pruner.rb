module ApproverPruner
  extend self

  def inactive_approvers
    User.where("bit_prefs & ? > 0", User.flag_value_for("can_approve_posts")).select do |user|
      approval_count = Post.where("created_at >= ? and approver_id = ?", 3.months.ago, user.id).count
      approval_count < 10
    end
  end

  def prune!
    inactive_approvers.each do |user|
      CurrentUser.scoped(User.system, "127.0.0.1") do
        next if user.is_admin?

        user.update!(can_approve_posts: false)
        user.feedback.create(category: "neutral", body: "Lost approval privileges")

        Dmail.create_automated(
          :to_id => user.id,
          :title => "Approver inactivity",
          :body => "You've approved fewer than 10 posts in the past three months. In order to make sure the list of active approvers is up-to-date, you have lost your approval privileges. If you wish to dispute this, you can message an admin to have your permission reinstated."
        )
      end
    end
  end
end
