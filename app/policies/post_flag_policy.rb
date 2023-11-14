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
    record.creator_id == user.id || (user.is_moderator? && record.post&.uploader_id != user.id)
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

  def visible_for_search(relation, attribute)
    case attribute
    in :creator | :creator_id if can_search_flagger?
      relation.where(creator: user).or(relation.where.not(post: user.posts))
    in :creator | :creator_id
      relation.where(creator: user)
    else
      relation
    end
  end
end
