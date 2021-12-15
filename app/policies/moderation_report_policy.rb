# frozen_string_literal: true

class ModerationReportPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end

  def show?
    !user.is_anonymous?
  end

  def create?
    unbanned? && policy(record.model).reportable?
  end

  def can_see_moderation_reports?
    user.is_moderator?
  end

  def permitted_attributes
    [:model_type, :model_id, :reason]
  end
end
