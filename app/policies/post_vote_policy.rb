class PostVotePolicy < ApplicationPolicy
  def create?
    unbanned? && user.is_gold?
  end

  def destroy?
    unbanned? && user.is_gold?
  end
end
