class ForumPostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.level >= record.topic.min_level
  end

  def create?
    unbanned? && policy(record.topic).reply?
  end

  def update?
    unbanned? && show? && (user.is_moderator? || (record.creator_id == user.id && !record.topic.is_locked?))
  end

  def destroy?
    unbanned? && show? && user.is_moderator?
  end

  def undelete?
    unbanned? && show? && user.is_moderator?
  end

  def votable?
    unbanned? && show? && record.bulk_update_request.present? && record.bulk_update_request.is_pending? && record.bulk_update_request.user_id != user.id
  end

  def reportable?
    unbanned? && show? && record.creator_id != user.id && !record.creator.is_moderator?
  end

  def show_deleted?
    !record.is_deleted? || user.is_moderator?
  end

  def permitted_attributes_for_create
    [:body, :topic_id]
  end

  def permitted_attributes_for_update
    [:body]
  end

  def html_data_attributes
    super + [[:topic, :is_deleted?]]
  end
end
