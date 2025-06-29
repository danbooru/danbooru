# frozen_string_literal: true

class FavoritePolicy < ApplicationPolicy
  def create?
    unbanned? && user.is_member?
  end

  def destroy?
    record.user_id == user.id
  end

  def can_see_favoriter?
    user.is_admin? || record.user == user || !record.user.enable_private_favorites?
  end

  def rate_limit_for_write(**_options)
    if user.post_votes.exists?(created_at: ..24.hours.ago)
      { action: "favorites:write", rate: 60.0 / 1.minute, burst: 100 } # 3600 per hour, 3700 in first hour
    else
      { action: "favorites:write", rate: 8.0 / 1.minute, burst: 60 } # 480 per hour, 540 in first hour
    end
  end
end
