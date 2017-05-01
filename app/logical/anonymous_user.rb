# This is a proxy class to make various nil checks unnecessary
class AnonymousUser
  def id
    nil
  end

  def level
    0
  end

  def comment_threshold
    0
  end

  def created_at
    Time.now
  end

  def updated_at
    Time.now
  end

  def dmail_filter
    nil
  end

  def name
    "Anonymous"
  end

  def pretty_name
    "Anonymous"
  end

  def is_anonymous?
    true
  end

  def is_banned?
    false
  end

  def is_banned_or_ip_banned?
    false
  end

  def has_mail?
    false
  end

  def has_forum_been_updated?
    false
  end

  def has_permission?(obj, foreign_key = :user_id)
    false
  end

  def ban
    false
  end

  def always_resize_images?
    false
  end

  def show_samples?
    true
  end

  def tag_subscriptions
    []
  end

  def favorite_tags
    nil
  end

  def upload_limit
    0
  end

  def base_upload_limit
    0
  end

  def uploaded_tags
    ""
  end

  def uploaded_tags_with_types
    []
  end

  def recent_tags
    ""
  end

  def recent_tags_with_types
    []
  end

  def can_upload?
    false
  end

  def can_comment?
    false
  end

  def is_comment_limited?
    true
  end

  def can_remove_from_pools?
    false
  end

  def can_approve_posts?
    false
  end

  def blacklisted_tags
    ["spoilers", "guro", "scat", "furry -rating:s"].join("\n")
  end

  def time_zone
    "Eastern Time (US & Canada)"
  end

  def default_image_size
    "large"
  end

  def email
    ""
  end

  def last_forum_read_at
    Time.now
  end

  def update_column(*params)
  end

  def increment!(field)
  end

  def decrement!(field)
  end
  
  def role
    :anonymous
  end

  def tag_query_limit
    2
  end

  def favorite_limit
    0
  end

  def favorite_count
    0
  end

  def enable_post_navigation
    true
  end

  def new_post_navigation_layout
    true
  end

  def enable_privacy_mode
    false
  end

  def enable_sequential_post_navigation
    true
  end

  def api_regen_multiplier
    1
  end
  
  def api_burst_limit
    5
  end
  
  def statement_timeout
    3_000
  end
  
  def per_page
    Danbooru.config.posts_per_page
  end
  
  def hide_deleted_posts?
    false
  end

  def style_usernames?
    false
  end

  def dmail_count
    ""
  end

  def enable_auto_complete
    true
  end

  def custom_style
    nil
  end

  def show_deleted_children?
    false
  end

  def saved_searches
    []
  end

  def has_saved_searches?
    false
  end

  def show_saved_searches?
    false
  end

  def favorite_groups
    []
  end

  def can_upload_free?
    false
  end

  def disable_categorized_saved_searches?
    false
  end

  def is_voter?
    false
  end

  def is_super_voter?
    false
  end

  def disable_tagged_filenames?
    false
  end

  %w(member banned gold builder platinum moderator admin).each do |name|
    define_method("is_#{name}?") do
      false
    end
  end
end
