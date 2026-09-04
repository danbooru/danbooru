# frozen_string_literal: true

# Demote all approvers who haven't approved at least 30 posts in the last 45
# days. Moderators and recently promoted approvers are exempt. Runs as a monthly
# maintenance task. Approvers who are facing demotion are sent a weekly warning
# dmail first, and are only actually demoted once they've had at least a week's
# notice.
#
# @see DanbooruMaintenance#monthly
module ApproverPruner
  module_function

  APPROVAL_PERIOD = 45.days
  MINIMUM_APPROVALS = 30

  WARNING_PERIOD = 21.days
  MINIMUM_WARNING_PERIOD = 7.days

  WARNING_TITLE = "You will lose approval privileges soon"

  def enabled?
    Danbooru.config.approver_pruning_enabled?.to_s.truthy?
  end

  # Get the list of inactive approvers.
  # @return [Array<User>] the list of inactive approvers
  def inactive_approvers
    recently_promoted_approvers = UserFeedback.where(created_at: APPROVAL_PERIOD.ago..).where_like(:body, "*You have been promoted to an Approver*").pluck(:user_id)

    approvers = User.where(level: User::Levels::APPROVER).where.not(id: recently_promoted_approvers)
    approvers.select do |approver|
      approver.post_approvals.where(created_at: APPROVAL_PERIOD.ago..).count < MINIMUM_APPROVALS
    end
  end

  # Get the list of inactive approvers who received a warning dmail at least a
  # week ago (and not so long ago that it's stale).
  # @return [Array<User>] the list of inactive approvers due for demotion
  def warned_inactive_approvers
    inactive_approvers.select do |approver|
      approver.dmails.received.exists?(title: WARNING_TITLE, created_at: WARNING_PERIOD.ago..MINIMUM_WARNING_PERIOD.ago)
    end
  end

  # Demote all inactive approvers who have already received a warning dmail
  def prune!
    return unless enabled?

    warned_inactive_approvers.each do |user|
      CurrentUser.scoped(User.system) do
        user.update!(level: User::Levels::CONTRIBUTOR)
        user.feedback.create!(category: "neutral", body: "Lost approval privileges", creator: User.system, disable_dmail_notification: true)

        Dmail.create_automated(
          to_id: user.id,
          title: "Approver inactivity",
          body: "You've approved fewer than #{MINIMUM_APPROVALS} posts in the past #{APPROVAL_PERIOD.inspect}. In order to make sure the list of active approvers is up-to-date, you have lost your approval privileges. If you wish to dispute this, you can message an admin to have your permission reinstated.",
        )
      end
    end
  end

  # Send a warning dmail to approvers who are pending demotion.
  def dmail_inactive_approvers!
    return unless enabled?
    return unless Date.current >= Date.current.next_month.beginning_of_month - WARNING_PERIOD

    days_until_next_month = (Date.current.next_month.beginning_of_month - Date.current).to_i

    inactive_approvers.each do |user|
      Dmail.create_automated(
        to: user,
        title: WARNING_TITLE,
        body: <<~BODY)
          You've approved fewer than #{MINIMUM_APPROVALS} posts in the past #{APPROVAL_PERIOD.inspect}.

          You will lose your approval privileges in #{days_until_next_month} #{"day".pluralize(days_until_next_month)} unless you have approved at least #{MINIMUM_APPROVALS} posts by the end of the month.
        BODY
    end
  end
end
