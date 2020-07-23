class UserPolicy < ApplicationPolicy
  def create?
    user.is_anonymous? && !sockpuppet?
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

  def api_attributes
    attributes = %i[
      id created_at name inviter_id level
      post_upload_count post_update_count note_update_count is_banned
      can_approve_posts can_upload_free level_string
    ]

    if record.id == user.id
      attributes += User::BOOLEAN_ATTRIBUTES
      attributes += %i[
        updated_at last_logged_in_at last_forum_read_at
        comment_threshold default_image_size
        favorite_tags blacklisted_tags time_zone per_page
        custom_style favorite_count api_regen_multiplier
        api_burst_limit remaining_api_limit statement_timeout
        favorite_group_limit favorite_limit tag_query_limit
        is_comment_limited?
        max_saved_searches theme
      ]
    end

    attributes
  end

  alias_method :profile?, :show?
  alias_method :settings?, :edit?
end
