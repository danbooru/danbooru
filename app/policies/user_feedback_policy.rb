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
