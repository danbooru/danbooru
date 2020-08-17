class PostPolicy < ApplicationPolicy
  def show_seq?
    true
  end

  def random?
    true
  end

  def update?
    unbanned? && record.visible?
  end

  def revert?
    update?
  end

  def copy_notes?
    update?
  end

  def mark_as_translated?
    update?
  end

  def move_favorites?
    user.is_approver? && record.fav_count > 0 && record.parent_id.present?
  end

  def delete?
    user.is_approver? && !record.is_deleted?
  end

  def destroy?
    delete?
  end

  def ban?
    user.is_approver? && !record.is_banned?
  end

  def unban?
    user.is_approver? && record.is_banned?
  end

  def expunge?
    user.is_admin?
  end

  def visible?
    record.visible?(user)
  end

  def can_lock_rating?
    user.is_builder?
  end

  def can_lock_notes?
    user.is_builder?
  end

  def can_lock_status?
    user.is_admin?
  end

  def can_use_mode_menu?
    user.is_gold?
  end

  def can_view_favlist?
    user.is_gold?
  end

  # whether to show the + - links in the tag list.
  def show_extra_links?
    user.is_gold?
  end

  def permitted_attributes
    [
      :tag_string, :old_tag_string, :parent_id, :old_parent_id,
      :source, :old_source, :rating, :old_rating, :has_embedded_notes,
      (:is_rating_locked if can_lock_rating?),
      (:is_note_locked if can_lock_notes?),
      (:is_status_locked if can_lock_status?),
    ].compact
  end

  def api_attributes
    attributes = super
    attributes += [:has_large, :has_visible_children, :is_favorited?]
    attributes += TagCategory.categories.map {|x| "tag_string_#{x}".to_sym}
    attributes += [:file_url, :large_file_url, :preview_file_url] if visible?
    attributes -= [:id, :md5, :file_ext] if !visible?
    attributes -= [:fav_string] if !user.is_moderator?
    attributes
  end

  def html_data_attributes
    super + [:has_large?, :current_image_size]
  end
end
