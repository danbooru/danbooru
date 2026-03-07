# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def can_change_category?
    return false if record.artist.present? && record.category == Tag.categories.artist
    return true if user.is_admin?
    return true if user.is_builder? && record.post_count < 1_000
    record.post_count < 50
  end

  def can_change_deprecated_status?
    return false if (record.wiki_page.blank? || record.wiki_page.is_deleted?) && !record.is_deprecated?
    user.is_admin? || (record.post_count == 0 && !record.is_deprecated?)
  end

  def permitted_attributes
    permitted = []
    permitted << :category if can_change_category?
    permitted << :is_deprecated if can_change_deprecated_status?
    permitted
  end
end
