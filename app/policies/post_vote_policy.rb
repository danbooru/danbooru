# frozen_string_literal: true

class PostVotePolicy < ApplicationPolicy
  def create?
    unbanned? && user.is_member?
  end

  def destroy?
    record.user == user || user.is_admin?
  end

  def show?
    user.is_moderator? || record.user == user || (record.is_positive? && !record.is_deleted?)
  end

  def can_see_voter?
    show?
  end

  def api_attributes
    attributes = super
    attributes -= [:user_id] unless can_see_voter?
    attributes
  end
end
