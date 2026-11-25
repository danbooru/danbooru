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
      { action: "favorites:write", rate: 60.0 / 1.minute, burst: 20 } # 3600 per hour, 3620 in first hour
    else
      { action: "favorites:write", rate: 8.0 / 1.minute, burst: 10 } # 480 per hour, 490 in first hour
    end
  end

  def visible(relation)
    if user.is_admin?
      relation
    elsif user.is_anonymous?
      relation.public_favorites
    else
      relation.where(user: user).or(relation.public_favorites)
    end
  end

  def searchable_attributes
    %i[id post user]
  end
end
