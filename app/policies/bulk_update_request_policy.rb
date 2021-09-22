class BulkUpdateRequestPolicy < ApplicationPolicy
  def create?
    unbanned? && (record.forum_topic.blank? || policy(record.forum_topic).reply?)
  end

  def update?
    unbanned? && (user.is_admin? || record.user_id == user.id)
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
