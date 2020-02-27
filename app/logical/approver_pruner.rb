module ApproverPruner
  module_function

  APPROVAL_PERIOD = 45.days
  MINIMUM_APPROVALS = 30

  def inactive_approvers
    approvers = User.bit_prefs_match(:can_approve_posts, true)
    approvers = approvers.where("level < ?", User::Levels::MODERATOR)

    recently_promoted_approvers = UserFeedback.where("created_at >= ?", APPROVAL_PERIOD.ago).where_like(:body, "*You gained the ability to approve posts*").select(:user_id)
    approvers = approvers.where.not(id: recently_promoted_approvers)

    approvers.select do |approver|
      approver.post_approvals.where("created_at >= ?", APPROVAL_PERIOD.ago).count < MINIMUM_APPROVALS
    end
  end

  def prune!
    inactive_approvers.each do |user|
      CurrentUser.scoped(User.system, "127.0.0.1") do
        user.update!(can_approve_posts: false)
        user.feedback.create(category: "neutral", body: "Lost approval privileges", creator: User.system)

        Dmail.create_automated(
          to_id: user.id,
          title: "Approver inactivity",
          body: "You've approved fewer than #{MINIMUM_APPROVALS} posts in the past #{APPROVAL_PERIOD.inspect}. In order to make sure the list of active approvers is up-to-date, you have lost your approval privileges. If you wish to dispute this, you can message an admin to have your permission reinstated."
        )
      end
    end
  end

  def dmail_inactive_approvers!
    days_until_next_month = (Date.current.next_month.beginning_of_month - Date.current).to_i
    return unless days_until_next_month <= 21

    inactive_approvers.each do |user|
      Dmail.create_automated(to: user, title: "You will lose approval privileges soon", body: <<~BODY)
        You've approved fewer than #{MINIMUM_APPROVALS} posts in the past
        #{APPROVAL_PERIOD.inspect}. You will lose your approval privileges in
        #{days_until_next_month} #{"day".pluralize(days_until_next_month)}
        unless you have approved at least #{MINIMUM_APPROVALS} posts by the end
        of the month.
      BODY
    end
  end
end
