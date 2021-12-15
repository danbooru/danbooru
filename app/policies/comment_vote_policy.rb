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
end
