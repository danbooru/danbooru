class IpBanPolicy < ApplicationPolicy
  def create?
    user.is_moderator?
  end

  def index?
    user.is_moderator?
  end

  def update?
    user.is_moderator?
  end

  def permitted_attributes
    [:ip_addr, :reason, :is_deleted, :category]
  end
end
