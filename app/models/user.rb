require 'digest/sha1'

class User < ApplicationRecord
  class Error < StandardError; end
  class PrivilegeError < StandardError; end

  module Levels
    ANONYMOUS = 0
    MEMBER = 20
    GOLD = 30
    PLATINUM = 31
    BUILDER = 32
    MODERATOR = 40
    ADMIN = 50
  end

  # Used for `before_action :<role>_only`. Must have a corresponding `is_<role>?` method.
  Roles = Levels.constants.map(&:downcase) + [
    :banned,
    :approver
  ]

  # candidates for removal:
  # - enable_post_navigation (disabled by 700)
  # - new_post_navigation_layout (disabled by 1364)
  # - enable_sequential_post_navigation (disabled by 680)
  # - hide_deleted_posts (enabled by 1904)
  # - disable_categorized_saved_searches (enabled by 2291)
  # - disable_tagged_filenames (enabled by 387)
  # - enable_recent_searches (enabled by 499)
  # - disable_cropped_thumbnails (enabled by 22)
  # - has_saved_searches
  # - opt_out_tracking
  # - enable_recommended_posts
  # - has_mail
  # - is_super_voter
  BOOLEAN_ATTRIBUTES = %w(
    is_banned
    has_mail
    receive_email_notifications
    always_resize_images
    enable_post_navigation
    new_post_navigation_layout
    enable_private_favorites
    enable_sequential_post_navigation
    hide_deleted_posts
    style_usernames
    enable_auto_complete
    show_deleted_children
    has_saved_searches
    can_approve_posts
    can_upload_free
    disable_categorized_saved_searches
    is_super_voter
    disable_tagged_filenames
    enable_recent_searches
    disable_cropped_thumbnails
    disable_mobile_gestures
    enable_safe_mode
    enable_desktop_mode
    disable_post_tooltips
    enable_recommended_posts
    opt_out_tracking
    no_flagging
    no_feedback
    requires_verification
    is_verified
  )

  has_bit_flags BOOLEAN_ATTRIBUTES, :field => "bit_prefs"

  attr_reader :password

  after_initialize :initialize_attributes, if: :new_record?
  validates :name, user_name: true, on: :create
  validates_length_of :password, :minimum => 5, :if => ->(rec) { rec.new_record? || rec.password.present?}
  validates_inclusion_of :default_image_size, :in => %w(large original)
  validates_inclusion_of :per_page, in: (1..PostSets::Post::MAX_PER_PAGE)
  validates_confirmation_of :password
  validates_presence_of :comment_threshold
  before_validation :normalize_blacklisted_tags
  before_create :promote_to_admin_if_first_user
  has_many :artist_versions, foreign_key: :updater_id
  has_many :artist_commentary_versions, foreign_key: :updater_id
  has_many :comments, foreign_key: :creator_id
  has_many :comment_votes, dependent: :destroy
  has_many :wiki_page_versions, foreign_key: :updater_id
  has_many :feedback, :class_name => "UserFeedback", :dependent => :destroy
  has_many :forum_post_votes, dependent: :destroy, foreign_key: :creator_id
  has_many :forum_topic_visits, dependent: :destroy
  has_many :visited_forum_topics, through: :forum_topic_visits, source: :forum_topic
  has_many :moderation_reports, as: :model
  has_many :posts, :foreign_key => "uploader_id"
  has_many :post_appeals, foreign_key: :creator_id
  has_many :post_approvals, :dependent => :destroy
  has_many :post_disapprovals, :dependent => :destroy
  has_many :post_flags, foreign_key: :creator_id
  has_many :post_votes
  has_many :post_versions, foreign_key: :updater_id
  has_many :bans, -> {order("bans.id desc")}
  has_one :recent_ban, -> {order("bans.id desc")}, :class_name => "Ban"

  has_one :api_key
  has_one :token_bucket
  has_one :email_address, dependent: :destroy
  has_many :note_versions, :foreign_key => "updater_id"
  has_many :dmails, -> {order("dmails.id desc")}, :foreign_key => "owner_id"
  has_many :saved_searches
  has_many :forum_topics, :foreign_key => "creator_id"
  has_many :forum_posts, -> {order("forum_posts.created_at, forum_posts.id")}, :foreign_key => "creator_id"
  has_many :user_name_change_requests, -> {order("user_name_change_requests.created_at desc")}
  has_many :favorite_groups, -> {order(name: :asc)}, foreign_key: :creator_id
  has_many :favorites, ->(rec) {where("user_id % 100 = #{rec.id % 100} and user_id = #{rec.id}").order("id desc")}
  has_many :ip_bans, foreign_key: :creator_id
  has_many :tag_aliases, foreign_key: :creator_id
  has_many :tag_implications, foreign_key: :creator_id
  belongs_to :inviter, class_name: "User", optional: true

  accepts_nested_attributes_for :email_address, reject_if: :all_blank, allow_destroy: true
  enum theme: { light: 0, dark: 100 }, _suffix: true

  # UserDeletion#rename renames deleted users to `user_<1234>~`. Tildes
  # are appended if the username is taken.
  scope :deleted, -> { where("name ~ 'user_[0-9]+~*'") }
  scope :undeleted, -> { where("name !~ 'user_[0-9]+~*'") }
  scope :admins, -> { where(level: Levels::ADMIN) }

  scope :has_blacklisted_tag, ->(name) { where_regex(:blacklisted_tags, "(^| )[~-]?#{Regexp.escape(name)}( |$)", flags: "ni") }

  module BanMethods
    def unban!
      self.is_banned = false
      save
    end

    def ban_expired?
      is_banned? && recent_ban.try(:expired?)
    end
  end

  concerning :NameMethods do
    class_methods do
      def name_to_id(name)
        find_by_name(name).try(:id)
      end

      # XXX should casefold instead of lowercasing.
      # XXX using lower(name) instead of ilike so we can use the index.
      def name_matches(name)
        where("lower(name) = ?", normalize_name(name)).limit(1)
      end

      def find_by_name(name)
        name_matches(name).first
      end

      def normalize_name(name)
        name.to_s.mb_chars.downcase.strip.tr(" ", "_").to_s
      end
    end

    def pretty_name
      name.gsub(/([^_])_+(?=[^_])/, "\\1 \\2")
    end
  end

  concerning :AuthenticationMethods do
    def password=(new_password)
      @password = new_password
      self.bcrypt_password_hash = BCrypt::Password.create(hash_password(new_password))
    end

    def authenticate_login_key(signed_user_id)
      signed_user_id.present? && id == Danbooru::MessageVerifier.new(:login).verify(signed_user_id) && self
    end

    def authenticate_api_key(key)
      api_key.present? && ActiveSupport::SecurityUtils.secure_compare(api_key.key, key) && self
    end

    def authenticate_password(password)
      BCrypt::Password.new(bcrypt_password_hash) == hash_password(password) && self
    end

    def hash_password(password)
      Digest::SHA1.hexdigest("choujin-steiner--#{password}--")
    end
  end

  module LevelMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def system
        User.find_by!(name: Danbooru.config.system_user)
      end

      def anonymous
        user = User.new(name: "Anonymous", level: Levels::ANONYMOUS, created_at: Time.now)
        user.freeze.readonly!
        user
      end

      def level_hash
        return {
          "Member" => Levels::MEMBER,
          "Gold" => Levels::GOLD,
          "Platinum" => Levels::PLATINUM,
          "Builder" => Levels::BUILDER,
          "Moderator" => Levels::MODERATOR,
          "Admin" => Levels::ADMIN
        }
      end

      def level_string(value)
        case value
        when Levels::ANONYMOUS
          "Anonymous"

        when Levels::MEMBER
          "Member"

        when Levels::BUILDER
          "Builder"

        when Levels::GOLD
          "Gold"

        when Levels::PLATINUM
          "Platinum"

        when Levels::MODERATOR
          "Moderator"

        when Levels::ADMIN
          "Admin"

        else
          ""
        end
      end
    end

    def promote_to!(new_level, options = {})
      UserPromotion.new(self, CurrentUser.user, new_level, options).promote!
    end

    def promote_to_admin_if_first_user
      return if Rails.env.test?

      if User.admins.count == 0
        self.level = Levels::ADMIN
        self.can_approve_posts = true
        self.can_upload_free = true
      end
    end

    def level_string_was
      level_string(level_was)
    end

    def level_string(value = nil)
      User.level_string(value || level)
    end

    def is_deleted?
      name.match?(/\Auser_[0-9]+~*\z/)
    end

    def is_restricted?
      requires_verification? && !is_verified?
    end

    def is_anonymous?
      level == Levels::ANONYMOUS
    end

    def is_member?
      level >= Levels::MEMBER
    end

    def is_builder?
      level >= Levels::BUILDER
    end

    def is_gold?
      level >= Levels::GOLD
    end

    def is_platinum?
      level >= Levels::PLATINUM
    end

    def is_moderator?
      level >= Levels::MODERATOR
    end

    def is_admin?
      level >= Levels::ADMIN
    end

    def is_approver?
      can_approve_posts?
    end
  end

  module EmailMethods
    def email_with_name
      "#{name} <#{email_address.address}>"
    end

    def can_receive_email?(require_verification: true)
      email_address.present? && email_address.is_deliverable? && (email_address.is_verified? || !require_verification)
    end
  end

  concerning :BlacklistMethods do
    class_methods do
      def rewrite_blacklists!(old_name, new_name)
        has_blacklisted_tag(old_name).find_each do |user|
          user.lock!
          user.rewrite_blacklist(old_name, new_name)
          user.save!
        end
      end
    end

    def rewrite_blacklist(old_name, new_name)
      self.blacklisted_tags.gsub!(/(?:^| )([-~])?#{Regexp.escape(old_name)}(?: |$)/i) { " #{$1}#{new_name} " }
    end

    def normalize_blacklisted_tags
      return unless blacklisted_tags.present?
      self.blacklisted_tags = self.blacklisted_tags.lines.map(&:strip).join("\n")
    end
  end

  module ForumMethods
    def has_forum_been_updated?
      return false unless is_gold?
      max_updated_at = ForumTopic.visible(self).active.maximum(:updated_at)
      return false if max_updated_at.nil?
      return true if last_forum_read_at.nil?
      return max_updated_at > last_forum_read_at
    end
  end

  module LimitMethods
    extend Memoist

    def max_saved_searches
      if is_platinum?
        1_000
      else
        250
      end
    end

    def is_comment_limited?
      if is_gold?
        false
      else
        Comment.where("creator_id = ? and created_at > ?", id, 1.hour.ago).count >= Danbooru.config.member_comment_limit
      end
    end

    def is_appeal_limited?
      return false if can_upload_free?
      upload_limit.free_upload_slots < UploadLimit::APPEAL_COST
    end

    def is_flag_limited?
      return false if has_unlimited_flags?
      post_flags.active.count >= 5
    end

    # Flags are unlimited if you're an approver or you have at least 30 flags
    # in the last 3 months and have a 70% flag success rate.
    def has_unlimited_flags?
      return true if can_approve_posts?

      recent_flags = post_flags.where("created_at >= ?", 3.months.ago)
      flag_ratio = recent_flags.succeeded.count / recent_flags.count.to_f
      recent_flags.count >= 30 && flag_ratio >= 0.70
    end

    def upload_limit
      @upload_limit ||= UploadLimit.new(self)
    end

    def tag_query_limit
      if is_platinum?
        Danbooru.config.base_tag_query_limit * 2
      elsif is_gold?
        Danbooru.config.base_tag_query_limit
      else
        2
      end
    end

    def favorite_limit
      if is_platinum?
        Float::INFINITY
      elsif is_gold?
        20_000
      else
        10_000
      end
    end

    def favorite_group_limit
      if is_platinum?
        10
      elsif is_gold?
        5
      else
        3
      end
    end

    def api_regen_multiplier
      # regen this amount per second
      if is_platinum?
        4
      elsif is_gold?
        2
      else
        1
      end
    end

    def api_burst_limit
      # can make this many api calls at once before being bound by
      # api_regen_multiplier refilling your pool
      if is_platinum?
        60
      elsif is_gold?
        30
      else
        10
      end
    end

    def remaining_api_limit
      token_bucket.try(:token_count) || api_burst_limit
    end

    def statement_timeout
      if Rails.env.development?
        60_000
      elsif is_platinum?
        9_000
      elsif is_gold?
        6_000
      else
        3_000
      end
    end
  end

  module ApiMethods
    # extra attributes returned for /users/:id.json but not for /users.json.
    def full_attributes
      %i[
        wiki_page_version_count artist_version_count
        artist_commentary_version_count pool_version_count
        forum_post_count comment_count favorite_group_count
        appeal_count flag_count positive_feedback_count
        neutral_feedback_count negative_feedback_count
      ]
    end

    def to_legacy_json
      return {
        "name" => name,
        "id" => id,
        "level" => level,
        "created_at" => created_at.strftime("%Y-%m-%d %H:%M")
      }.to_json
    end

    def api_token
      api_key.try(:key)
    end
  end

  module CountMethods
    def wiki_page_version_count
      wiki_page_versions.count
    end

    def artist_version_count
      artist_versions.count
    end

    def artist_commentary_version_count
      artist_commentary_versions.count
    end

    def pool_version_count
      return nil unless PoolVersion.enabled?
      PoolVersion.for_user(id).count
    end

    def forum_post_count
      forum_posts.count
    end

    def comment_count
      comments.count
    end

    def favorite_group_count
      favorite_groups.visible(CurrentUser.user).count
    end

    def appeal_count
      post_appeals.count
    end

    def flag_count
      post_flags.count
    end

    def positive_feedback_count
      feedback.undeleted.positive.count
    end

    def neutral_feedback_count
      feedback.undeleted.neutral.count
    end

    def negative_feedback_count
      feedback.undeleted.negative.count
    end

    def refresh_counts!
      self.class.without_timeout do
        User.where(id: id).update_all(
          post_upload_count: posts.count,
          post_update_count: post_versions.count,
          note_update_count: note_versions.count
        )
      end
    end
  end

  module SearchMethods
    def search(params)
      q = super

      params = params.dup
      params[:name_matches] = params.delete(:name) if params[:name].present?

      q = q.search_attributes(params, :name, :level, :post_upload_count, :post_update_count, :note_update_count, :favorite_count)

      if params[:name_matches].present?
        q = q.where_ilike(:name, normalize_name(params[:name_matches]))
      end

      if params[:min_level].present?
        q = q.where("level >= ?", params[:min_level].to_i)
      end

      if params[:max_level].present?
        q = q.where("level <= ?", params[:max_level].to_i)
      end

      %w[can_approve_posts can_upload_free is_banned].each do |flag|
        if params[flag].to_s.truthy?
          q = q.bit_prefs_match(flag, true)
        elsif params[flag].to_s.falsy?
          q = q.bit_prefs_match(flag, false)
        end
      end

      if params[:current_user_first].to_s.truthy? && !CurrentUser.is_anonymous?
        q = q.order(Arel.sql("id = #{CurrentUser.id} desc"))
      end

      case params[:order]
      when "name"
        q = q.order("name")
      when "post_upload_count"
        q = q.order("post_upload_count desc")
      when "note_count"
        q = q.order("note_update_count desc")
      when "post_update_count"
        q = q.order("post_update_count desc")
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  include BanMethods
  include LevelMethods
  include EmailMethods
  include ForumMethods
  include LimitMethods
  include ApiMethods
  include CountMethods
  extend SearchMethods

  def initialize_attributes
    self.enable_post_navigation = true
    self.new_post_navigation_layout = true
    self.enable_sequential_post_navigation = true
    self.enable_auto_complete = true
    self.always_resize_images = true
  end

  def presenter
    @presenter ||= UserPresenter.new(self)
  end

  def dtext_shortlink(**options)
    "<@#{name}>"
  end

  def self.searchable_includes
    [:posts, :note_versions, :artist_commentary_versions, :post_appeals, :post_approvals, :artist_versions, :comments, :wiki_page_versions, :feedback, :forum_topics, :forum_posts, :forum_post_votes, :tag_aliases, :tag_implications, :bans, :inviter]
  end

  def self.available_includes
    [:inviter]
  end
end
