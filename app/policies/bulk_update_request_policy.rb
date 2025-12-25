# frozen_string_literal: true

class BulkUpdateRequestPolicy < ApplicationPolicy
  def create?
    unbanned? && (record.forum_topic.blank? || policy(record.forum_topic).reply?)
  end

  def update?
    unbanned? && !record.is_approved? && (user.is_admin? || record.user_id == user.id)
  end

  def approve?
    unbanned? && !record.is_approved? && (user.is_admin? || (user.is_builder? && record.is_tag_move_allowed?))
  end

  def destroy?
    record.is_pending? && update?
  end

  def can_update_forum?
    user.is_admin?
  end

  def rate_limit_for_write(**_options)
    if record.invalid?
      { action: "bulk_update_requests:write:invalid", rate: 1.0 / 1.second, burst: 1 }
    elsif user.is_admin?
      { action: "bulk_update_requests:write", rate: 1.0 / 1.second, burst: 50 }
    elsif user.is_builder?
      { action: "bulk_update_requests:write", rate: 1.0 / 1.minute, burst: 20 }
    elsif user.bulk_update_requests.exists?(created_at: ..4.hours.ago)
      { action: "bulk_update_requests:write", rate: 1.0 / 1.minute, burst: 20 }
    else
      { action: "bulk_update_requests:write", rate: 1.0 / 1.minute, burst: 5 }
    end
  end

  def permitted_attributes_for_create
    [:script, :title, :reason, :forum_topic_id]
  end

  def permitted_attributes_for_update
    if can_update_forum?
      [:script, :forum_topic_id, :forum_post_id]
    else
      [:script]
    end
  end
end
