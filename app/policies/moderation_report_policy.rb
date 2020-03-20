class ModerationReportPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def create?
    unbanned? && policy(record.model).reportable?
  end

  def permitted_attributes
    [:model_type, :model_id, :reason]
  end
end
