# frozen_string_literal: true

class UserFeedbackPolicy < ApplicationPolicy
  def create?
    unbanned? && user.is_gold? && record.user_id != user.id
  end

  def update?
    create? && (user.is_moderator? || (record.creator_id == user.id && !record.is_deleted?))
  end

  def show?
    !record.is_deleted? || can_view_deleted?
  end

  def can_view_deleted?
    user.is_moderator?
  end

  def can_see_updater_notice?
    user.is_moderator?
  end

  def rate_limit_for_write(**_options)
    if user.is_moderator?
      { action: "user_feedbacks:write", rate: 1.0 / 1.minute, burst: 60 } # 60 per hour, 120 in first hour
    else
      { action: "user_feedbacks:write", rate: 1.0 / 1.minute, burst: 5 } # 60 per hour, 65 in first hour
    end
  end

  def permitted_attributes_for_create
    [:body, :category, :user_id, :user_name]
  end

  def permitted_attributes_for_update
    [:body, :category, :is_deleted]
  end

  def html_data_attributes
    super + [:category]
  end
end
