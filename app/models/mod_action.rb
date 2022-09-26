# frozen_string_literal: true

class ModAction < ApplicationRecord
  belongs_to :creator, :class_name => "User"
  belongs_to :subject, polymorphic: true, optional: true

  # ####DIVISIONS#####
  # Groups:     0-999
  # Individual: 1000-1999
  # ####Actions#####
  # Create:   0
  # Update:   1
  # Delete:   2
  # Undelete: 3
  # Ban:      4
  # Unban:    5
  # Misc:     6-19
  enum category: {
    user_delete: 2,
    user_ban: 4,
    user_unban: 5,
    user_name_change: 6,
    user_level_change: 7,
    user_approval_privilege: 8,
    user_upload_privilege: 9,
    user_account_upgrade: 19, # XXX unused
    user_feedback_update: 21,
    user_feedback_delete: 22,
    post_delete: 42,
    post_undelete: 43,
    post_ban: 44,
    post_unban: 45,
    post_permanent_delete: 46,
    post_move_favorites: 47,
    post_regenerate: 48,
    post_regenerate_iqdb: 49,
    post_note_lock_create: 210,
    post_note_lock_delete: 212,
    post_rating_lock_create: 220,
    post_rating_lock_delete: 222,
    post_vote_delete: 232,
    post_vote_undelete: 233,
    pool_delete: 62,
    pool_undelete: 63,
    artist_ban: 184,
    artist_unban: 185,
    comment_update: 81,
    comment_delete: 82,
    comment_vote_delete: 92,
    comment_vote_undelete: 93,
    forum_topic_delete: 202,
    forum_topic_undelete: 203,
    forum_topic_lock: 206,
    forum_post_update: 101,
    forum_post_delete: 102,
    moderation_report_handled: 306,
    moderation_report_rejected: 307,
    tag_alias_create: 120,
    tag_alias_update: 121, # XXX unused
    tag_alias_delete: 122,
    tag_implication_create: 140,
    tag_implication_update: 141, # XXX unused
    tag_implication_delete: 142,
    tag_deprecate: 240,
    tag_undeprecate: 242,
    ip_ban_create: 160,
    ip_ban_delete: 162,
    ip_ban_undelete: 163,
    mass_update: 1000, # XXX unused
  }

  def self.model_types
    %w[Artist Comment CommentVote ForumPost ForumTopic IpBan ModerationReport Pool Post PostVote Tag TagAlias TagImplication User]
  end

  def self.visible(user)
    if user.is_moderator?
      all
    else
      where.not(category: [:ip_ban_create, :ip_ban_delete, :ip_ban_undelete, :moderation_report_handled, :moderation_report_rejected])
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :category, :description, :creator, :subject], current_user: current_user)

    case params[:order]
    when "created_at_asc"
      q = q.order(created_at: :asc, id: :asc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def category_id
    self.class.categories[category]
  end

  def self.log(description, category, subject:, user:)
    create!(description: description, category: category, subject: subject, creator: user)
  end

  def self.available_includes
    [:creator]
  end
end
