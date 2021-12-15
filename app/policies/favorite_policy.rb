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
end
