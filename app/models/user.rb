# frozen_string_literal: true

class User < ApplicationRecord
  extend Memoist

  class PrivilegeError < StandardError; end

  module Levels
    ANONYMOUS = 0
    RESTRICTED = 10
    MEMBER = 20
    GOLD = 30
    PLATINUM = 31
    BUILDER = 32
    MODERATOR = 40
    ADMIN = 50
    OWNER = 60
  end

  # Used for `before_action :<role>_only`. Must have a corresponding `is_<role>?` method.
  Roles = Levels.constants.map(&:downcase) + %i[banned approver]

  BOOLEAN_ATTRIBUTES = %w[
    is_banned
    _unused_has_mail
    receive_email_notifications
    _unused_always_resize_images
    _unused_enable_post_navigation
    new_post_navigation_layout
    enable_private_favorites
    _unused_enable_sequential_post_navigation
    _unused_hide_deleted_posts
    style_usernames
    _unused_enable_auto_complete
    show_deleted_children
    _unused_has_saved_searches
    can_approve_posts
    can_upload_free
    disable_categorized_saved_searches
    _unused_is_super_voter
    disable_tagged_filenames
    _unused_enable_recent_searches
    _unused_disable_cropped_thumbnails
    disable_mobile_gestures
    enable_safe_mode
    enable_desktop_mode
    disable_post_tooltips
    _unused_enable_recommended_posts
    _unused_opt_out_tracking
    _unused_no_flagging
    _unused_no_feedback
    requires_verification
    is_verified
    show_deleted_posts
  ]

  ACTIVE_BOOLEAN_ATTRIBUTES = BOOLEAN_ATTRIBUTES.grep_v(/unused/)

  DEFAULT_BLACKLIST = ["guro", "scat", "furry -rating:g"].join("\n")

  attribute :id
  attribute :created_at
  attribute :updated_at
  attribute :name
  attribute :level, default: Levels::MEMBER
  attribute :bcrypt_password_hash
  attribute :inviter_id
  attribute :last_logged_in_at, default: -> { Time.zone.now }
  attribute :last_forum_read_at, default: "1960-01-01 00:00:00"
  attribute :last_ip_addr, :ip_address
  attribute :comment_threshold, default: -8
  attribute :default_image_size, default: "large"
  attribute :favorite_tags
  attribute :blacklisted_tags, default: DEFAULT_BLACKLIST
  attribute :time_zone, default: "Eastern Time (US & Canada)"
  attribute :custom_style
  attribute :post_upload_count, default: 0
  attribute :post_update_count, default: 0
  attribute :note_update_count, default: 0
  attribute :unread_dmail_count, default: 0
  attribute :favorite_count, default: 0
  attribute :per_page, default: 20
  attribute :theme, default: :auto
  attribute :upload_points, default: Danbooru.config.initial_upload_points.to_i
  attribute :bit_prefs, default: 0

  has_bit_flags BOOLEAN_ATTRIBUTES, :field => "bit_prefs"
  enum theme: { auto: 0, light: 50, dark: 100 }, _suffix: true

  attr_reader :password

  after_initialize :initialize_attributes, if: :new_record?
  validates :name, user_name: true, on: :create
  validates :password, length: { minimum: 5 }, if: ->(rec) { rec.new_record? || rec.password.present? }
  validates :default_image_size, inclusion: { in: %w[large original] }
  validates :per_page, inclusion: { in: (1..PostSets::Post::MAX_PER_PAGE) }
  validates :password, confirmation: true
  validates :comment_threshold, inclusion: { in: (-100..5) }
  validate  :validate_enable_private_favorites, on: :update
  validate  :validate_custom_css, if: :custom_style_changed?
  before_validation :normalize_blacklisted_tags
  before_create :promote_to_owner_if_first_user

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
  has_many :post_events, class_name: "PostEvent", foreign_key: :creator_id
  has_many :post_flags, foreign_key: :creator_id
  has_many :post_votes
  has_many :post_versions, foreign_key: :updater_id
  has_many :bans, -> {order("bans.id desc")}
  has_many :received_upgrades, class_name: "UserUpgrade", foreign_key: :recipient_id, dependent: :destroy
  has_many :purchased_upgrades, class_name: "UserUpgrade", foreign_key: :purchaser_id, dependent: :destroy
  has_many :user_events, dependent: :destroy
  has_one :active_ban, -> { active }, class_name: "Ban"
  has_one :email_address, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :note_versions, :foreign_key => "updater_id"
  has_many :dmails, -> {order("dmails.id desc")}, :foreign_key => "owner_id"
  has_many :saved_searches
  has_many :forum_topics, :foreign_key => "creator_id"
  has_many :forum_posts, -> {order("forum_posts.created_at, forum_posts.id")}, :foreign_key => "creator_id"
  has_many :user_name_change_requests, -> {order("user_name_change_requests.created_at desc")}
  has_many :favorite_groups, -> {order(name: :asc)}, foreign_key: :creator_id
  has_many :favorites
  has_many :ip_bans, foreign_key: :creator_id
  has_many :tag_aliases, foreign_key: :creator_id
  has_many :tag_implications, foreign_key: :creator_id
  has_many :uploads, foreign_key: :uploader_id, dependent: :destroy
  has_many :upload_media_assets, through: :uploads, dependent: :destroy
  has_many :mod_actions, as: :subject, dependent: :destroy
  belongs_to :inviter, class_name: "User", optional: true

  accepts_nested_attributes_for :email_address, reject_if: :all_blank, allow_destroy: true

  # UserDeletion#rename renames deleted users to `user_<1234>~`. Tildes
  # are appended if the username is taken.
  scope :deleted, -> { where("name ~ 'user_[0-9]+~*'") }
  scope :undeleted, -> { where("name !~ 'user_[0-9]+~*'") }
  scope :admins, -> { where(level: Levels::ADMIN) }

  scope :has_blacklisted_tag, ->(name) { where_regex(:blacklisted_tags, "(^| )[~-]?#{Regexp.escape(name)}( |$)", flags: "ni") }
  scope :has_private_favorites, -> { bit_prefs_match(:enable_private_favorites, true) }
  scope :has_public_favorites,  -> { bit_prefs_match(:enable_private_favorites, false) }

  module BanMethods
    def unban!
      self.is_banned = false
      save
    end

    def ban_expired?
      is_banned? && active_ban.blank?
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
        name.to_s.downcase.strip.tr(" ", "_").to_s
      end
    end

    def pretty_name
      name.gsub(/([^_])_+(?=[^_])/, "\\1 \\2")
    end
  end

  concerning :ValidationMethods do
    def validate_enable_private_favorites
      if enable_private_favorites_was == false && enable_private_favorites == true && !Pundit.policy!(self, self).can_enable_private_favorites?
        errors.add(:base, "Can't enable privacy mode without a Gold account")
      end
    end

    def name_errors
      User.validators_on(:name).each do |validator|
        validator.validate_each(self, :name, name)
      end

      errors
    end

    def name_invalid?
      name_errors.present?
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
      api_key = api_keys.find_by(key: key)
      api_key.present? && ActiveSupport::SecurityUtils.secure_compare(api_key.key, key) && [self, api_key]
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
      def owner
        User.find_by!(level: Levels::OWNER)
      end

      def system
        User.find_by!(name: Danbooru.config.system_user)
      end

      def anonymous
        user = User.new(name: "Anonymous", level: Levels::ANONYMOUS, created_at: Time.zone.now)
        user.freeze.readonly!
        user
      end

      def level_hash
        {
          "Restricted" => Levels::RESTRICTED,
          "Member" => Levels::MEMBER,
          "Gold" => Levels::GOLD,
          "Platinum" => Levels::PLATINUM,
          "Builder" => Levels::BUILDER,
          "Moderator" => Levels::MODERATOR,
          "Admin" => Levels::ADMIN,
          "Owner" => Levels::OWNER,
        }
      end

      def level_string(value)
        case value
        when Levels::ANONYMOUS
          "Anonymous"

        when Levels::RESTRICTED
          "Restricted"

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

        when Levels::OWNER
          "Owner"

        else
          ""
        end
      end
    end

    def promote_to!(new_level, promoter = CurrentUser.user, **options)
      UserPromotion.new(self, promoter, new_level, **options).promote!
    end

    def promote_to_owner_if_first_user
      return if Rails.env.test?

      if name != Danbooru.config.system_user && !User.exists?(level: Levels::OWNER)
        self.level = Levels::OWNER
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

    def is_anonymous?
      level == Levels::ANONYMOUS
    end

    def is_restricted?
      level == Levels::RESTRICTED
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

    def is_owner?
      level >= Levels::OWNER
    end

    def is_approver?
      can_approve_posts?
    end
  end

  module EmailMethods
    def can_receive_email?(require_verified_email: true)
      email_address.present? && email_address.is_deliverable? && (email_address.is_verified? || !require_verified_email)
    end

    def change_email(new_email, request)
      transaction do
        update(email_address_attributes: { address: new_email })

        if errors.none?
          UserEvent.create_from_request!(self, :email_change, request)
          UserMailer.with_request(request).email_change_confirmation(self).deliver_later
        end
      end
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
      blacklisted_tags.gsub!(/(?:^| )([-~])?#{Regexp.escape(old_name)}(?: |$)/i) { " #{$1}#{new_name} " }
    end

    def normalize_blacklisted_tags
      return unless blacklisted_tags.present?
      self.blacklisted_tags = blacklisted_tags.lines.map(&:strip).join("\n")
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

  concerning :LimitMethods do
    class_methods do
      def statement_timeout(level)
        if Rails.env.development?
          60_000
        elsif level >= User::Levels::PLATINUM
          9_000
        elsif level == User::Levels::GOLD
          6_000
        else
          3_000
        end
      end

      def page_limit(level)
        if level >= User::Levels::GOLD
          5000
        else
          1000
        end
      end

      def tag_query_limit(level)
        if level >= User::Levels::MEMBER && Danbooru.config.is_promotion?
          Float::INFINITY
        elsif level >= User::Levels::PLATINUM
          Float::INFINITY
        elsif level == User::Levels::GOLD
          6
        else
          2
        end
      end

      def favorite_group_limit(level)
        if level >= User::Levels::GOLD
          Float::INFINITY
        else
          10
        end
      end

      def max_saved_searches(level)
        if level >= User::Levels::BUILDER
          Float::INFINITY
        elsif level >= User::Levels::GOLD
          1_000
        else
          250
        end
      end

      # regen this amount per second
      def api_regen_multiplier(level)
        if level >= User::Levels::GOLD
          4
        else
          1
        end
      end
    end

    def max_saved_searches
      User.max_saved_searches(level)
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

    def page_limit
      User.page_limit(level)
    end

    def tag_query_limit
      User.tag_query_limit(level)
    end

    def favorite_group_limit
      User.favorite_group_limit(level)
    end

    def api_regen_multiplier
      User.api_regen_multiplier(level)
    end

    def statement_timeout
      User.statement_timeout(level)
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
  end

  concerning :CountMethods do
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
      comments.visible_for_search(:creator, CurrentUser.user).count
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

  concerning :CustomCssMethods do
    def custom_css
      CustomCss.new(custom_style)
    end

    def validate_custom_css
      if !custom_css.valid?
        errors.add(:base, "Custom CSS contains a syntax error. Validate it with https://codebeautify.org/cssvalidate")
      end
    end
  end

  module SearchMethods
    def search(params, current_user)
      params = params.dup
      params[:name_matches] = params.delete(:name) if params[:name].present?

      q = search_attributes(
        params,
        [:id, :created_at, :updated_at, :name, :level, :post_upload_count,
        :post_update_count, :note_update_count, :favorite_count, :posts,
        :note_versions, :artist_commentary_versions, :post_appeals,
        :post_approvals, :artist_versions, :comments, :wiki_page_versions,
        :feedback, :forum_topics, :forum_posts, :forum_post_votes,
        :tag_aliases, :tag_implications, :bans, :inviter],
        current_user: current_user
      )

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
        q = q.order(name: :asc)
      when "post_upload_count"
        q = q.order(post_upload_count: :desc)
      when "note_count"
        q = q.order(note_update_count: :desc)
      when "post_update_count"
        q = q.order(post_update_count: :desc)
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
  include ApiMethods
  extend SearchMethods

  def initialize_attributes
    self.new_post_navigation_layout = true
  end

  def presenter
    @presenter ||= UserPresenter.new(self)
  end

  def dtext_shortlink(**options)
    "<@#{name}>"
  end

  def self.available_includes
    [:inviter, :bans]
  end

  memoize :name_errors
end
