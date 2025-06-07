# frozen_string_literal: true

class WikiPagePolicy < ApplicationPolicy
  def show_or_new?
    true
  end

  def update?
    unbanned? && (can_edit_locked? || !record.is_locked?)
  end

  def revert?
    update?
  end

  def can_edit_locked?
    user.is_builder?
  end

  def can_see_updater_notice?
    user.is_moderator?
  end

  def permitted_attributes
    [:title, :body, :other_names, :other_names_string, :is_deleted, (:is_locked if can_edit_locked?)].compact
  end
end
