# frozen_string_literal: true

class PostFlagPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    unbanned? && record.pending? && record.creator_id == user.id
  end

  def can_search_flagger?
    user.is_moderator?
  end

  def can_view_flagger?
    (user.is_moderator? || record.creator_id == user.id) && (record.post&.uploader_id != user.id)
  end

  def permitted_attributes_for_create
    [:post_id, :reason]
  end

  def permitted_attributes_for_update
    [:reason]
  end

  def api_attributes
    attributes = super + [:category]
    attributes -= [:creator_id] unless can_view_flagger?
    attributes
  end
end
