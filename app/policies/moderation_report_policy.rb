# frozen_string_literal: true

class ModerationReportPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end

  def show?
    !user.is_anonymous?
  end

  def create?
    unbanned? && policy(record.model).try(:reportable?)
  end

  def update?
    user.is_moderator?
  end

  def can_see_moderation_reports?
    user.is_moderator?
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 1.minute, burst: 10 }
  end

  def permitted_attributes_for_create
    [:model_type, :model_id, :reason]
  end

  def permitted_attributes_for_update
    [:status]
  end
end
