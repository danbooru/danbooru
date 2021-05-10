class CommentVotePolicy < ApplicationPolicy
  def create?
    unbanned? && !record.comment.is_deleted?
  end

  def destroy?
    !record.is_deleted? && (record.user_id == user.id || user.is_admin?)
  end

  def can_see_votes?
    user.is_moderator?
  end
end
