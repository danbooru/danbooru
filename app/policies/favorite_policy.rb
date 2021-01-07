class FavoritePolicy < ApplicationPolicy
  def create?
    !user.is_anonymous?
  end

  def destroy?
    !user.is_anonymous?
  end
end
