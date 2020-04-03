class CommentVotePolicy < ApplicationPolicy
  def destroy?
    # XXX permissions are checked in Comment#unvote!
    true
  end

  def can_see_votes?
    user.is_moderator?
  end
end
