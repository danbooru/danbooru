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
    { rate: 1.0 / 1.second, burst: 200 }
  end

  def api_attributes
    attributes = super
    attributes -= [:user_id] unless can_see_voter?
    attributes
  end
end
