# frozen_string_literal: true

class PoolPolicy < ApplicationPolicy
  def gallery?
    index?
  end

  def update?
    unbanned? && (!record.is_deleted? || user.is_builder?)
  end

  def destroy?
    !record.is_deleted? && user.is_builder?
  end

  def undelete?
    record.is_deleted? && user.is_builder?
  end

  def revert?
    update?
  end

  def rate_limit_for_write(**_options)
    if user.is_moderator?
      { action: "pools:write", rate: 8.0 / 1.minute, burst: 120 } # 480 per hour, 600 in first hour
    elsif user.is_builder?
      { action: "pools:write", rate: 4.0 / 1.minute, burst: 60 } # 240 per hour, 300 in first hour
    elsif user.pool_versions.exists?(created_at: ..24.hours.ago)
      { action: "pools:write", rate: 2.0 / 1.minute, burst: 30 } # 120 per hour, 150 in first hour
    else
      { action: "pools:write", rate: 1.0 / 1.5.minutes, burst: 10 } # 40 per hour, 50 in first hour
    end
  end

  def permitted_attributes
    [:name, :description, :category, :post_ids, :post_ids_string, { post_ids: [] }]
  end

  def api_attributes
    super + [:post_count]
  end
end
