class CommentPolicy < ApplicationPolicy
  def update?
    unbanned? && (user.is_moderator? || record.updater_id == user.id)
  end

  def reportable?
    unbanned? && record.creator_id != user.id && !record.creator.is_moderator?
  end

  def can_sticky_comment?
    user.is_moderator?
  end

  def permitted_attributes_for_create
    [:body, :post_id, :do_not_bump_post, (:is_sticky if can_sticky_comment?)].compact
  end

  def permitted_attributes_for_update
    [:body, :is_deleted, (:is_sticky if can_sticky_comment?)].compact
  end

  alias_method :undelete?, :update?
end
