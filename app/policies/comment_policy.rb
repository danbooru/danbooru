class CommentPolicy < ApplicationPolicy
  def create?
    unbanned?
  end

  def update?
    unbanned? && (user.is_moderator? || (record.updater_id == user.id && !record.is_deleted?))
  end

  def reportable?
    unbanned? && record.creator_id != user.id && !record.creator.is_moderator? && !record.is_deleted?
  end

  def can_sticky_comment?
    user.is_moderator?
  end

  def can_see_deleted?
    user.is_moderator?
  end

  def reply?
    !record.is_deleted?
  end

  def permitted_attributes_for_create
    [:body, :post_id, :do_not_bump_post, (:is_sticky if can_sticky_comment?)].compact
  end

  def permitted_attributes_for_update
    [:body, :is_deleted, (:is_sticky if can_sticky_comment?)].compact
  end

  def api_attributes
    attributes = super
    attributes -= [:creator_id, :updater_id, :body] if record.is_deleted? && !can_see_deleted?
    attributes
  end

  alias_method :undelete?, :update?
end
