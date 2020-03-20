class FavoritePolicy < ApplicationPolicy
  def create?
    user.is_member?
  end

  def destroy?
    user.is_member?
  end
end
