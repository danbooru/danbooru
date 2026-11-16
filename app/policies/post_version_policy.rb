# frozen_string_literal: true

class PostVersionPolicy < ApplicationPolicy
  def undo?
    unbanned? && record.version > 1 && record.post.present? && policy(record.post).visible?
  end

  def can_mass_undo?
    user.is_builder?
  end

  def searchable_attributes
    %i[id updated_at updater_id post_id tags added_tags removed_tags rating rating_changed parent_id parent_changed source source_changed version]
  end

  def api_attributes
    super + [:obsolete_added_tags, :obsolete_removed_tags, :unchanged_tags]
  end
end
