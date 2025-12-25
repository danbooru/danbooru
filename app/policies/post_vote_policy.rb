# frozen_string_literal: true

class PostVotePolicy < ApplicationPolicy
  def create?
    unbanned? && user.is_member?
  end

  def destroy?
    record.user == user || user.is_admin?
  end

  def show?
    user.is_admin? || record.user == user || (record.is_positive? && !record.is_deleted? && !record.user.enable_private_favorites?)
  end

  def can_see_voter?
    show?
  end

  def rate_limit_for_write(**_options)
    if record.is_positive? && user.post_votes.exists?(created_at: ..24.hours.ago)
      { action: "post_votes:write", rate: 60.0 / 1.minute, burst: 100 } # 3600 per hour, 3700 in first hour
    elsif record.is_negative? && user.post_votes.exists?(created_at: ..24.hours.ago)
      { action: "post_votes:write", rate: 30.0 / 1.minute, burst: 100 } # 1800 per hour, 1900 in first hour
    elsif record.is_positive?
      { action: "post_votes:write", rate: 8.0 / 1.minute, burst: 60 } # 480 per hour, 540 in first hour
    else # record.is_negative?
      { action: "post_votes:write", rate: 1.0 / 1.minute, burst: 40 } # 60 per hour, 100 in first hour
    end
  end

  def api_attributes
    attributes = super
    attributes -= [:user_id] unless can_see_voter?
    attributes
  end
end
