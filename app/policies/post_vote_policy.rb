class PostVotePolicy < ApplicationPolicy
  def create?
    unbanned? && user.is_member?
  end

  def destroy?
    unbanned? && record.user == user
  end

  def show?
    user.is_admin? || record.user == user || (record.is_positive? && !record.user.enable_private_favorites?)
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
