class PostVersionPolicy < ApplicationPolicy
  def undo?
    unbanned? && record.version > 1 && record.post.present? && policy(record.post).visible?
  end

  def can_mass_undo?
    user.is_builder?
  end
end
