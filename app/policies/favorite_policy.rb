class FavoritePolicy < ApplicationPolicy
  def create?
    !user.is_anonymous?
  end

  def destroy?
    record.user_id == user.id
  end
end
