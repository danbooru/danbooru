# frozen_string_literal: true

class ForumPostVotePolicy < ApplicationPolicy
  def create?
    unbanned? && policy(record.forum_post).votable?
  end

  def destroy?
    unbanned? && record.creator_id == user.id && policy(record.forum_post).votable?
  end

  def rate_limit_for_write(**_options)
    if user.forum_post_votes.exists?(created_at: ..24.hours.ago)
      { action: "forum_post_votes:write", rate: 4.0 / 1.minute, burst: 20 } # 240 per hour, 260 in first hour
    else
      { action: "forum_post_votes:write", rate: 1.0 / 1.minute, burst: 10 } # 60 per hour, 70 in first hour
    end
  end

  def permitted_attributes
    [:score]
  end
end
