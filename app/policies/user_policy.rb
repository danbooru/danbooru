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

  def deactivate?
    (record.id == user.id && !user.is_anonymous?) || user.is_owner?
  end

  def destroy?
    deactivate?
  end

  def promote?
    user.is_moderator?
  end

  def fix_counts?
    !user.is_anonymous?
  end

  def can_see_last_logged_in_at?
    user.is_moderator?
  end

  def add_extra_data_attributes?
    user.is_gold?
  end

  def permitted_attributes_for_create
    [:name, :password, :password_confirmation, { email_address_attributes: [:address] }]
  end

  def permitted_attributes_for_update
    %i[
      comment_threshold default_image_size favorite_tags
      blacklisted_tags time_zone per_page custom_style theme
      receive_email_notifications new_post_navigation_layout
      show_deleted_posts show_deleted_children
      disable_categorized_saved_searches disable_tagged_filenames
      disable_mobile_gestures enable_safe_mode
      enable_desktop_mode disable_post_tooltips
      show_niche_posts add_extra_data_attributes
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

    attributes += [:last_ip_addr] if policy(:ip_address).show?

    attributes
  end

  alias_method :profile?, :show?
  alias_method :settings?, :edit?
end
