class UserPolicy < ApplicationPolicy
  def create?
    !sockpuppet?
  end

  def update?
    record.id == user.id || user.is_admin?
  end

  def promote?
    user.is_moderator?
  end

  def upgrade?
    user.is_member?
  end

  def reportable?
    false
  end

  def fix_counts?
    user.is_member?
  end

  def can_see_favorites?
    user.is_admin? || record.id == user.id || !record.enable_private_favorites?
  end

  def sockpuppet?
    User.where(last_ip_addr: request.remote_ip).where("created_at > ?", 1.day.ago).exists?
  end

  def permitted_attributes_for_create
    [:name, :password, :password_confirmation, { email_address_attributes: [:address] }]
  end

  def permitted_attributes_for_update
    [
      :comment_threshold, :default_image_size, :favorite_tags,
      :blacklisted_tags, :time_zone, :per_page, :custom_style, :theme,
      :receive_email_notifications, :always_resize_images,
      :enable_post_navigation, :new_post_navigation_layout,
      :enable_private_favorites, :enable_sequential_post_navigation,
      :hide_deleted_posts, :style_usernames, :enable_auto_complete,
      :show_deleted_children, :disable_categorized_saved_searches,
      :disable_tagged_filenames, :disable_cropped_thumbnails,
      :disable_mobile_gestures, :enable_safe_mode, :enable_desktop_mode,
      :disable_post_tooltips,
      (:level if CurrentUser.is_admin?)
    ].compact
  end

  alias_method :profile?, :show?
  alias_method :settings?, :edit?
end
