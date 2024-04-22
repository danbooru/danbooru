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
    CONTRIBUTOR = 35
    APPROVER = 37
    MODERATOR = 40
    ADMIN = 50
    OWNER = 60
  end

  # Used for `before_action :<role>_only`. Must have a corresponding `is_<role>?` method.
  Roles = Levels.constants.map(&:downcase) + %i[banned]

  BOOLEAN_ATTRIBUTES = %w[
    is_banned
    show_extra_links
    receive_email_notifications
    nest_tags
    _unused_enable_post_navigation
    new_post_navigation_layout
    _unused_enable_private_favorites
    _unused_enable_sequential_post_navigation
    _unused_hide_deleted_posts
    _unused_style_usernames
    _unused_enable_auto_complete
    show_deleted_children
    _unused_has_saved_searches
    _unused_can_approve_posts
    _unused_can_upload_free
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
    add_extra_data_attributes
    show_niche_posts
    requires_verification
    is_verified
    show_deleted_posts
  ]

  ACTIVE_BOOLEAN_ATTRIBUTES = BOOLEAN_ATTRIBUTES.grep_v(/unused/)

  # Personal preferences that are editable by the user, rather than internal flags. These will be cleared when the user deactivates their account.
  USER_PREFERENCE_BOOLEAN_ATTRIBUTES = ACTIVE_BOOLEAN_ATTRIBUTES - %w[is_banned requires_verification is_verified]

  DEFAULT_BLACKLIST = ["guro", "scat"].join("\n")

  # The number of backup codes to generate for a user.
  MAX_BACKUP_CODES = 3

  # The number of digits in each backup code.
  BACKUP_CODE_LENGTH = 8

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
  attribute :per_page, default: Danbooru.config.posts_per_page.to_i
  attribute :theme, default: :auto
  attribute :upload_points, default: Danbooru.config.initial_upload_points.to_i
  attribute :bit_prefs, default: 0
  attribute :is_deleted, default: false

  has_bit_flags BOOLEAN_ATTRIBUTES, :field => "bit_prefs"
  enum theme: { auto: 0, light: 50, dark: 100 }, _suffix: true

  attr_reader :password

  after_initialize :initialize_attributes, if: :new_record?
  validates :name, user_name: true, on: :create
  validates :password, length: { minimum: 5 }, if: ->(rec) { rec.new_record? || rec.password.present? }
  validates :default_image_size, inclusion: { in: %w[large original] }
  validates :per_page, inclusion: { in: (1..PostSets::Post::MAX_PER_PAGE) }
  validates :password, confirmation: { message: "Passwords don't match" }
  validates :comment_threshold, inclusion: { in: (-100..5) }
  validate :validate_custom_css, if: :custom_style_changed?
  validate :validate_add_extra_data_attributes, unless: :new_record?
  before_validation :normalize_blacklisted_tags
  before_create :promote_to_owner_if_first_user

  has_many :ai_metadata_versions, foreign_key: :updater_id
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
  has_many :pool_versions, foreign_key: :updater_id
  has_many :posts, :foreign_key => "uploader_id"
  has_many :post_appeals, foreign_key: :creator_id
  has_many :post_approvals, :dependent => :destroy
  has_many :post_disapprovals, :dependent => :destroy
  has_many :post_events, class_name: "PostEvent", foreign_key: :creator_id
  has_many :post_flags, foreign_key: :creator_id
  has_many :post_votes
  has_many :post_versions, foreign_key: :updater_id
  has_many :bans, -> {order("bans.id desc")}
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

  scope :admins, -> { where(level: Levels::ADMIN) }
  scope :banned, -> { bit_prefs_match(:is_banned, true) }

  scope :has_blacklisted_tag, ->(name) { where_regex(:blacklisted_tags, "(^| )[~-]?#{Regexp.escape(name)}( |$)", flags: "ni") }

  deletable

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

      # Find the user who is currently using this name, or if nobody is, find the user(s) that have used this name in the past.
      def name_or_past_name_matches(name, current_user:)
        users = name_matches(name).load

        if users.one?
          users
        else
          past_name_matches(name, current_user:)
        end
      end

      # Find all users that have ever used this name, past or present.
      def any_name_matches(name, current_user:)
        # A UNION is faster than an OR for this query because the OR results in a full table scan.
        # name_matches(name).or(past_name_matches(name, current_user:))
        where_union(name_matches(name), past_name_matches(name, current_user:))
      end

      def name_matches(name)
        where("lower(name) = ?", normalize_name(name))
      end

      def past_name_matches(name, current_user:)
        where(id: UserNameChangeRequest.visible(current_user).where_iequals(:original_name, normalize_name(name)).select(:user_id))
      end

      def find_by_name_or_email(name_or_email)
        find_by_name(name_or_email) || find_by_email(name_or_email)
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
    def validate_add_extra_data_attributes
      if !add_extra_data_attributes_was && add_extra_data_attributes_was && !Pundit.policy!(self, self).add_extra_data_attributes?
        errors.add(:base, "Can't enable extra data attributes without a Gold account")
      end
    end

    def name_errors
      UserNameValidator.new(attributes: [:name], skip_uniqueness: true).validate(self)
      errors
    end

    def name_invalid?
      name_errors.present?
    end
  end

  concerning :PasswordMethods do
    def password=(new_password)
      @password = new_password
      self.bcrypt_password_hash = BCrypt::Password.create(hash_password(new_password))
    end

    def request_password_reset!(request)
      with_lock do
        if can_receive_email?(require_verified_email: false)
          UserMailer.with_request(request).password_reset(self).deliver_later
        end

        UserEvent.create_from_request!(self, :password_reset_request, request)
      end
    end

    def reset_password(new_password:, password_confirmation:, verification_code:, request:)
      if is_deleted?
        errors.add(:base, "You can't reset the password of a deleted account")
        false
      elsif totp.present? && !totp.verify(verification_code) && !has_backup_code?(verification_code)
        UserEvent.create_from_request!(self, :totp_failed_reauthenticate, request)
        errors.add(:verification_code, "is incorrect")
        false
      else
        with_lock do
          UserEvent.build_from_request(self, :password_reset, request)
          success = update(password: new_password, password_confirmation: password_confirmation)
          verify_backup_code!(verification_code) if success
          success
        end
      end
    end

    def change_password(current_user:, current_password:, new_password:, password_confirmation:, verification_code:, request:)
      if self != current_user && PasswordPolicy.new(current_user, self).can_change_user_passwords?
        UserEvent.build_from_request(self, :password_change, request)
        update(password: new_password, password_confirmation: password_confirmation)
      elsif !authenticate_password(current_password)
        UserEvent.create_from_request!(self, :failed_reauthenticate, request)
        errors.add(:current_password, "is incorrect")
        false
      elsif totp.present? && !totp.verify(verification_code)
        UserEvent.create_from_request!(self, :totp_failed_reauthenticate, request)
        errors.add(:verification_code, "is incorrect")
        false
      else
        UserEvent.build_from_request(self, :password_change, request)
        update(password: new_password, password_confirmation: password_confirmation)
      end
    end
  end

  concerning :AuthenticationMethods do
    # @return [Array<(User, ApiKey)>, Boolean] Return a (User, ApiKey) pair if the API key is correct, or false if it isn't.
    def authenticate_api_key(key)
      return false if is_deleted?
      api_key = api_keys.find_by(key: key)
      api_key.present? && ActiveSupport::SecurityUtils.secure_compare(api_key.key, key) && [self, api_key]
    end

    # @return [User, Boolean] Return the user if the password is correct, or false if it isn't.
    def authenticate_password(password)
      return false if is_deleted?
      BCrypt::Password.new(bcrypt_password_hash) == hash_password(password) && self
    end

    def hash_password(password)
      Digest::SHA1.hexdigest("choujin-steiner--#{password}--")
    end
  end

  concerning :TOTPMethods do
    extend Memoist

    # @return [TOTP, nil] Return a 2FA code verifier if the user has 2FA enabled, or nil if 2FA is not enabled.
    memoize def totp
      TOTP.new(totp_secret, username: name) if totp_secret.present?
    end

    # Add a secret to enable 2FA, or delete it to disable 2FA, or change it to use new 2FA codes.
    #
    # @param secret [String] The 16-character base-32 encoded secret.
    # @param request [ActionDispatch::Request] The HTTP request.
    def update_totp_secret!(secret, request:)
      with_lock do
        update!(totp_secret: secret)
        flush_cache # clear memoized totp

        if totp_secret_before_last_save.nil?
          UserEvent.create_from_request!(self, :totp_enable, request)
          generate_backup_codes!(request)
        elsif secret.nil?
          UserEvent.create_from_request!(self, :totp_disable, request)
          update!(backup_codes: nil)
        else
          UserEvent.create_from_request!(self, :totp_update, request)
        end
      end
    end
  end

  concerning :BackupCodeMethods do
    # Check whether the given backup code is correct. If it is, remove it and generate a new backup code.
    #
    # @param backup_code [String] The backup code to verify.
    def verify_backup_code!(backup_code)
      if has_backup_code?(backup_code)
        replace_backup_code!(backup_code)
        true
      else
        false
      end
    end

    # Return true if the given backup code is correct.
    def has_backup_code?(backup_code)
      return false unless backup_code.to_s.strip.match?(/\A[0-9]+\z/)
      backup_codes.include?(backup_code.to_s.strip.to_i)
    end

    # Replace the given backup code with a new one.
    def replace_backup_code!(backup_code)
      with_lock do
        return unless has_backup_code?(backup_code)
        backup_code = backup_code.strip.to_i
        new_backup_codes = backup_codes.without(backup_code) + [generate_backup_code]
        update!(backup_codes: new_backup_codes)
      end
    end

    # Generate a new set of backup codes.
    #
    # @param request [ActionDispatch::Request] The HTTP request.
    # @param max_codes [Integer] The number of backup codes to generate.
    # @param length [Integer] The number of digits in each backup code.
    def generate_backup_codes!(request, max_codes: MAX_BACKUP_CODES, length: BACKUP_CODE_LENGTH)
      with_lock do
        update!(backup_codes: max_codes.times.map { generate_backup_code(length) })
        UserEvent.create_from_request!(self, :backup_code_generate, request)
      end
    end

    def generate_backup_code(length = BACKUP_CODE_LENGTH)
      SecureRandom.rand(10**length)
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
          "Contributor" => Levels::CONTRIBUTOR,
          "Approver" => Levels::APPROVER,
          "Moderator" => Levels::MODERATOR,
          "Admin" => Levels::ADMIN,
          "Owner" => Levels::OWNER,
        }
      end

      def level_string(value)
        level_hash.key(value)
      end
    end

    def promote_to!(new_level, promoter = CurrentUser.user)
      UserPromotion.new(self, promoter, new_level).promote!
    end

    def promote_to_owner_if_first_user
      return if Rails.env.test?

      if name != Danbooru.config.system_user && !User.exists?(level: Levels::OWNER)
        self.level = Levels::OWNER
      end
    end

    def level_string_was
      level_string(level_was)
    end

    def level_string(value = nil)
      User.level_string(value || level)
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

    def is_gold?
      level >= Levels::GOLD
    end

    def is_platinum?
      level >= Levels::PLATINUM
    end

    def is_builder?
      level >= Levels::BUILDER
    end

    def is_contributor?
      level >= Levels::CONTRIBUTOR
    end

    def is_approver?
      level >= Levels::APPROVER
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
  end

  concerning :EmailMethods do
    class_methods do
      # @param email_address [String] The user's email address.
      def find_by_email(email_address)
        normalized_address = Danbooru::EmailAddress.canonicalize(email_address).to_s
        User.joins(:email_address).find_by(email_address: { normalized_address: normalized_address })
      end
    end

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
          user.with_lock do
            user.rewrite_blacklist(old_name, new_name)
            user.save!
          end
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
          4
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
      return false if is_contributor?
      upload_limit.free_upload_slots < UploadLimit::APPEAL_COST
    end

    def is_flag_limited?
      return false if has_unlimited_flags?
      post_flags.active.count >= 5
    end

    # Flags are unlimited if you're an approver.
    def has_unlimited_flags?
      return true if is_approver?
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

    def show_ads?
      !CurrentUser.safe_mode? && !is_member?
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
    def unposted_upload_count
      uploads.completed.undeleted.where.missing(:posts).count
    end

    def wiki_page_version_count
      wiki_page_versions.count
    end

    def artist_version_count
      artist_versions.count
    end

    def artist_commentary_version_count
      artist_commentary_versions.count
    end

    def ai_metadata_version_count
      ai_metadata_versions.count
    end

    def pool_version_count
      pool_versions.count
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
        [:id, :created_at, :updated_at, :name, :level, :is_deleted, :post_upload_count, :post_update_count,
         :note_update_count, :favorite_count, :posts, :note_versions, :artist_commentary_versions, :post_appeals,
         :post_approvals, :artist_versions, :comments, :wiki_page_versions, :feedback, :forum_topics, :forum_posts,
         :forum_post_votes, :tag_aliases, :tag_implications, :bans, :inviter],
        current_user: current_user
      )

      if params[:name_matches].present?
        q = q.where_ilike(:name, normalize_name(params[:name_matches]))
      end

      if params[:any_name_matches].present?
        q = q.any_name_matches(params[:any_name_matches], current_user:)
      end

      if params[:name_or_past_name_matches].present?
        q = q.name_or_past_name_matches(params[:name_or_past_name_matches], current_user:)
      end

      if params[:min_level].present?
        q = q.where("level >= ?", params[:min_level].to_i)
      end

      if params[:max_level].present?
        q = q.where("level <= ?", params[:max_level].to_i)
      end

      if params[:is_banned].present?
        if params[:is_banned].to_s.truthy?
          q = q.bit_prefs_match(:is_banned, true)
        elsif params[:is_banned].to_s.falsy?
          q = q.bit_prefs_match(:is_banned, false)
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

  concerning :DiscordMethods do
    def discord_author
      Discordrb::Webhooks::EmbedAuthor.new(name:, url: discord_url)
    end

    def discord_title
      is_banned? ? "~~#{name}~~" : name
    end

    def discord_color
      return 0xED2426 if is_banned?
      case level
      in Levels::GOLD
        0xEAD084
      in Levels::PLATINUM
        0xABABBC
      in Levels::BUILDER | Levels::CONTRIBUTOR | Levels::APPROVER
        0xC979FF
      in Levels::MODERATOR
        0x35C64A
      in Levels::ADMIN | Levels::OWNER
        0xFF8A8B
      else
        nil
      end
    end

    def discord_fields
      [
        Discordrb::Webhooks::EmbedField.new(inline: true, name: "Level", value: is_banned? ? "Banned" : level_string),
        Discordrb::Webhooks::EmbedField.new(inline: true, name: "Uploads", value: "#{post_upload_count} (#{posts.deleted.count} deleted)"),
        Discordrb::Webhooks::EmbedField.new(inline: true, name: "Comments", value: comments.visible(User.anonymous).count),
        Discordrb::Webhooks::EmbedField.new(inline: true, name: "Forum posts", value: forum_posts.visible(User.anonymous).count),
        Discordrb::Webhooks::EmbedField.new(inline: true, name: "Post edits", value: post_update_count),
        Discordrb::Webhooks::EmbedField.new(inline: true, name: "Artist edits", value: artist_version_count),
      ]
    end

    def discord_footer
      timestamp = "#{created_at.strftime("%F")}"

      Discordrb::Webhooks::EmbedFooter.new(
        text: "#{positive_feedback_count}⇧ #{neutral_feedback_count}😐 #{negative_feedback_count}⇩ | Joined #{timestamp}"
      )
    end
  end

  include BanMethods
  include LevelMethods
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

  def reload(...)
    flush_cache # flush memoize cache
    super
  end

  def self.available_includes
    [:inviter, :bans]
  end

  memoize :name_errors
end
