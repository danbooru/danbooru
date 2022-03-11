# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def can_change_category?
    return true if user.is_admin?
    return false if record.category == TagCategory.mapping["deprecated"]
    return true if user.is_builder? && record.post_count < 1_000
    return true if user.is_member? && record.post_count < 50
    false
  end

  def permitted_attributes
    [(:category if can_change_category?)].compact
  end
end
