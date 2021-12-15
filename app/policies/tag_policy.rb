# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def can_change_category?
    user.is_admin? ||
      (user.is_builder? && record.post_count < 1_000) ||
      (user.is_member? && record.post_count < 50)
  end

  def permitted_attributes
    [(:category if can_change_category?)].compact
  end
end
