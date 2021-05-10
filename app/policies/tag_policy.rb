class TagPolicy < ApplicationPolicy
  def can_change_category?
    user.is_admin? ||
      (user.is_builder? && !record.is_locked? && record.post_count < 1_000) ||
      (user.is_member? && !record.is_locked? && record.post_count < 50)
  end

  def can_lock?
    user.is_moderator?
  end

  def permitted_attributes
    [(:category if can_change_category?), (:is_locked if can_lock?)].compact
  end
end
