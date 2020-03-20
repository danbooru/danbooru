class PostFlagPolicy < ApplicationPolicy
  def can_search_flagger?
    user.is_moderator?
  end

  def can_view_flagger?
    (user.is_moderator? || record.creator_id == user.id) && (record.post&.uploader_id != user.id)
  end

  def permitted_attributes
    [:post_id, :reason]
  end
end
