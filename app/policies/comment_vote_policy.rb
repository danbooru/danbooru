class CommentVotePolicy < ApplicationPolicy
  def destroy?
    # XXX permissions are checked in Comment#unvote!
    true
  end
end
