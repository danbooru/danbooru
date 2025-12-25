# frozen_string_literal: true

class CommentVotePolicy < ApplicationPolicy
  def create?
    unbanned? && !record.comment.is_deleted?
  end

  def destroy?
    !record.is_deleted? && (record.user_id == user.id || user.is_admin?)
  end

  def show?
    can_see_votes? || record.user == user
  end

  def can_see_votes?
    user.is_moderator?
  end

  def rate_limit_for_write(**_options)
    if user.comment_votes.exists?(created_at: ..24.hours.ago)
      { action: "comment_votes:write", rate: 8.0 / 1.minute, burst: 60 } # 480 per hour, 540 in first hour
    else
      { action: "comment_votes:write", rate: 1.0 / 1.minute, burst: 30 } # 60 per hour, 90 in first hour
    end
  end
end
