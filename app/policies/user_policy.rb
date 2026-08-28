# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create?
    user.is_anonymous?
  end

  def new?
    user.is_anonymous?
  end

  def custom_style?
    record == user
  end

  def edit?
    record.id == user.id || user.is_superadmin?
  end

  def update?
    record.id == user.id
  end

  def deactivate?
    (record.id == user.id && !user.is_anonymous?) || user.is_superadmin?
  end

  def destroy?
    deactivate?
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

  def can_see_last_ip_addr?
    policy(:ip_address).show? && (record.id == user.id || record.level < user.level)
  end

  def can_see_flag_count?
    record.id == user.id || user.is_moderator?
  end

  def can_see_favorites?
    user.is_admin? || record.id == user.id || !record.enable_private_favorites?
  end

  def can_enable_private_favorites?
    user.is_gold?
  end

  def can_recover_account?
    user.is_admin? && record.level < user.level && record.level < User::Levels::MODERATOR
  end

  def rate_limit_for_create(**_options)
    if record.invalid?([:create, :deliverable])
      { action: "users:create:invalid", rate: 1.0 / 1.second, burst: 10 }
    else
      { action: "users:create", rate: 1.0 / 5.minutes, burst: 3 }
    end
  end

  def permitted_attributes_for_create
    [:name, :password, :password_confirmation]
  end

  def permitted_attributes_for_update
    %i[
      comment_threshold default_image_size favorite_tags
      blacklisted_tags time_zone per_page custom_style theme
      receive_email_notifications
      new_post_navigation_layout enable_private_favorites
      show_deleted_posts show_deleted_children
      disable_categorized_saved_searches disable_tagged_filenames
      disable_mobile_gestures enable_safe_mode
      enable_desktop_mode disable_post_tooltips
    ].compact
  end

  def api_attributes
    attributes = %i[
      id created_at name inviter_id level level_string
      post_upload_count post_update_count note_update_count is_banned is_deleted
    ]

    if record.id == user.id
      attributes += User::ACTIVE_BOOLEAN_ATTRIBUTES
      attributes += %i[
        updated_at last_logged_in_at last_forum_read_at
        comment_threshold default_image_size
        favorite_tags blacklisted_tags time_zone per_page
        custom_style favorite_count statement_timeout favorite_group_limit
        tag_query_limit max_saved_searches theme
      ]
    end

    attributes += [:last_ip_addr] if can_see_last_ip_addr?

    attributes
  end

  # Extra attributes returned for /users/:id.json but not for /users.json.
  def full_api_attributes
    attributes = %i[
      wiki_page_version_count artist_version_count
      artist_commentary_version_count pool_version_count
      forum_post_count comment_count favorite_group_count
      appeal_count positive_feedback_count
      neutral_feedback_count negative_feedback_count
    ]

    attributes += [:flag_count] if can_see_flag_count?

    attributes
  end

  alias_method :profile?, :show?
  alias_method :settings?, :edit?
  alias_method :demote?, :promote?
end
