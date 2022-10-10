# frozen_string_literal: true

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

  def create?
    unbanned? && record.uploader == user
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

  def regenerate?
    user.is_moderator?
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

  def can_use_mode_menu?
    user.is_gold?
  end

  # whether to show the + - links in the tag list.
  def show_extra_links?
    user.is_gold?
  end

  def permitted_attributes_for_create
    %i[upload_id media_asset_id upload_media_asset_id tag_string rating
    parent_id source is_pending artist_commentary_desc artist_commentary_title
    translated_commentary_desc translated_commentary_title]
  end

  # XXX For UploadsController#show action
  def permitted_attributes_for_show
    %i[tag_string rating parent_id source is_pending artist_commentary_desc
    artist_commentary_title translated_commentary_desc translated_commentary_title]
  end

  def permitted_attributes_for_update
    %i[tag_string old_tag_string parent_id old_parent_id source old_source rating old_rating has_embedded_notes]
  end

  def api_attributes
    attributes = super
    attributes += [:has_large, :has_visible_children]
    attributes += TagCategory.categories.map {|x| "tag_string_#{x}".to_sym}
    attributes += [:file_url, :large_file_url, :preview_file_url] if visible?
    attributes -= [:md5] if !visible?
    attributes
  end

  def html_data_attributes
    super + [:has_large?, :current_image_size]
  end
end
