module ApproverPruner
  module_function

  APPROVAL_PERIOD = 45.days
  MINIMUM_APPROVALS = 30

  def inactive_approvers
    approvals = PostApproval.where("created_at >= ?", APPROVAL_PERIOD.ago)
    approvers = User.where("bit_prefs & ? > 0", User.flag_value_for("can_approve_posts")).where("level < ?", User::Levels::MODERATOR)
    approvers.where(id: approvals.group(:user_id).having("count(*) < ?", MINIMUM_APPROVALS).select(:user_id))
  end

  def prune!
    inactive_approvers.each do |user|
      CurrentUser.scoped(User.system, "127.0.0.1") do
        user.update!(can_approve_posts: false)
        user.feedback.create(category: "neutral", body: "Lost approval privileges")

        Dmail.create_automated(
          to_id: user.id,
          title: "Approver inactivity",
          body: "You've approved fewer than #{MINIMUM_APPROVALS} posts in the past #{APPROVAL_PERIOD.inspect}. In order to make sure the list of active approvers is up-to-date, you have lost your approval privileges. If you wish to dispute this, you can message an admin to have your permission reinstated."
        )
      end
    end
  end
end
