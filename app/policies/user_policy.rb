# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create?
    true
  end

  def new?
    true
  end

  def update?
    record.id == user.id || user.is_admin?
  end

  def promote?
    user.is_moderator?
  end

  def upgrade?
    !user.is_anonymous?
  end

  def fix_counts?
    !user.is_anonymous?
  end

  def can_see_last_logged_in_at?
    user.is_moderator?
  end

  def can_see_favorites?
    user.is_admin? || record.id == user.id || !record.enable_private_favorites?
  end

  def can_enable_private_favorites?
    user.is_gold?
  end

  def permitted_attributes_for_create
    [:name, :password, :password_confirmation, { email_address_attributes: [:address] }]
  end

  def permitted_attributes_for_update
    %i[
      comment_threshold default_image_size favorite_tags
      blacklisted_tags time_zone per_page custom_style theme
      receive_email_notifications always_resize_images
      new_post_navigation_layout enable_private_favorites
      style_usernames show_deleted_children
      disable_categorized_saved_searches disable_tagged_filenames
      disable_mobile_gestures enable_safe_mode
      enable_desktop_mode disable_post_tooltips
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
        custom_style favorite_count statement_timeout favorite_group_limit
        tag_query_limit max_saved_searches theme
      ]
    end

    attributes
  end

  alias_method :profile?, :show?
  alias_method :settings?, :edit?
end
