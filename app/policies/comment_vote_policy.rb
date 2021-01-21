class CommentVotePolicy < ApplicationPolicy
  def create?
    unbanned? && !record.comment.is_deleted?
  end

  def destroy?
    record.user_id == user.id
  end

  def can_see_votes?
    user.is_moderator?
  end
end
