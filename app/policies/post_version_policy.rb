class PostVersionPolicy < ApplicationPolicy
  def undo?
    unbanned? && record.version > 1 && record.post.present? && policy(record.post).visible?
  end

  def can_mass_undo?
    user.is_builder?
  end

  def api_attributes
    super + [:obsolete_added_tags, :obsolete_removed_tags, :unchanged_tags]
  end
end
