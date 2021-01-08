class UserSessionPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end
end
