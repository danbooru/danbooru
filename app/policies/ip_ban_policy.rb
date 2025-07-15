# frozen_string_literal: true

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

  def rate_limit_for_write(**_options)
    { action: "ip_bans:write", rate: 1.0 / 1.minute, burst: 60 } # 60 per hour, 120 in first hour
  end

  def permitted_attributes
    [:ip_addr, :reason, :is_deleted, :category]
  end
end
