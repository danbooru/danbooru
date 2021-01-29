class PostVotePolicy < ApplicationPolicy
  def create?
    unbanned? && user.is_gold?
  end

  def destroy?
    unbanned? && record.user == user
  end
end
