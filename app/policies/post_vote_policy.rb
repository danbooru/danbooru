class PostVotePolicy < ApplicationPolicy
  def create?
    unbanned? && user.is_gold?
  end

  def destroy?
    unbanned? && record.user == user
  end

  def show?
    user.is_admin? || record.user == user
  end
end
