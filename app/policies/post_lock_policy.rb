class PostLockPolicy < ApplicationPolicy
  def index?
    user.is_builder?
  end

  def create_or_update?
    user.is_builder?
  end

  def moderate?
    user.is_moderator?
  end

  PostLock::ALL_TYPES.each do |type|
    define_method("lock_#{type}?") do
      if builder_locks.include?("#{type}_lock".to_sym)
        user.is_builder?
      elsif moderator_locks.include?("#{type}_lock".to_sym)
        user.is_moderator?
      elsif admin_locks.include?("#{type}_lock".to_sym)
        user.is_admin?
      end
    end
  end

  def set_duration?
    user.is_moderator?
  end

  def set_locks_with_post_edits?
    user.is_moderator?
  end

  def builder_locks
    [:tags_lock, :rating_lock, :parent_lock, :source_lock, :notes_lock, :commentary_lock, :pools_lock]
  end

  def moderator_locks
    [:comments_lock]
  end

  def admin_locks
    [:status_lock]
  end

  def permitted_locks
    @permitted_locks ||= begin
      locks = []
      locks += builder_locks if user.is_builder?
      locks += moderator_locks if user.is_moderator?
      locks += admin_locks if user.is_admin?
      locks
    end
  end

  def permitted_attributes
    @permitted_attributes ||= begin
      attributes = permitted_locks
      attributes += [:post_id, :reason] if user.is_builder?
      attributes += [:duration, :edit_level] if user.is_moderator?
      attributes
    end
  end

  def api_attributes
    super + PostLock::ALL_LOCKS.map(&:to_sym) + PostLock::ALL_CHANGES.map(&:to_sym)
  end
end
