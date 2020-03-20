class IpBanPolicy < ApplicationPolicy
  def create?
    user.is_moderator?
  end

  def index?
    user.is_moderator?
  end

  def destroy?
    user.is_moderator?
  end

  def permitted_attributes
    [:ip_addr, :reason]
  end
end
