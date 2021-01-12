class UserSessionPolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end
end
