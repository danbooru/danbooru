require 'digest/sha1'
require 'danbooru/has_bit_flags'

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
    :approver,
    :voter,
    :super_voter
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
    disable_responsive_mode
    disable_post_tooltips
    enable_recommended_posts
    opt_out_tracking
    no_flagging
    no_feedback
  )

  include Danbooru::HasBitFlags
  has_bit_flags BOOLEAN_ATTRIBUTES, :field => "bit_prefs"

  attr_accessor :password, :old_password

  after_initialize :initialize_attributes, if: :new_record?
  validates :name, user_name: true, on: :create
  validates_uniqueness_of :email, :case_sensitive => false, :if => ->(rec) { rec.email.present? && rec.saved_change_to_email? }
  validates_length_of :password, :minimum => 5, :if => ->(rec) { rec.new_record? || rec.password.present?}
  validates_inclusion_of :default_image_size, :in => %w(large original)
  validates_inclusion_of :per_page, in: (1..PostSets::Post::MAX_PER_PAGE)
  validates_confirmation_of :password
  validates_presence_of :comment_threshold
  validate :validate_ip_addr_is_not_banned, :on => :create
  validate :validate_sock_puppets, :on => :create, :if => -> { Danbooru.config.enable_sock_puppet_validation? }
  before_validation :normalize_blacklisted_tags
  before_validation :set_per_page
  before_validation :normalize_email
  before_create :encrypt_password_on_create
  before_update :encrypt_password_on_update
  before_create :promote_to_admin_if_first_user
  before_create :customize_new_user
  has_many :artists, foreign_key: :creator_id
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
  has_many :pools, foreign_key: :creator_id
  has_many :posts, :foreign_key => "uploader_id"
  has_many :post_appeals, foreign_key: :creator_id
  has_many :post_approvals, :dependent => :destroy
  has_many :post_disapprovals, :dependent => :destroy
  has_many :post_flags, foreign_key: :creator_id
  has_many :post_votes
  has_many :post_versions, class_name: "PostArchive", foreign_key: :updater_id
  has_many :bans, -> {order("bans.id desc")}
  has_one :recent_ban, -> {order("bans.id desc")}, :class_name => "Ban"

  has_one :api_key
  has_one :super_voter
  has_one :token_bucket
  has_many :notes, foreign_key: :creator_id
  has_many :note_versions, :foreign_key => "updater_id"
  has_many :dmails, -> {order("dmails.id desc")}, :foreign_key => "owner_id"
  has_many :saved_searches
  has_many :forum_posts, -> {order("forum_posts.created_at, forum_posts.id")}, :foreign_key => "creator_id"
  has_many :user_name_change_requests, -> {visible.order("user_name_change_requests.created_at desc")}
  has_many :favorite_groups, -> {order(name: :asc)}, foreign_key: :creator_id
  has_many :favorites, ->(rec) {where("user_id % 100 = #{rec.id % 100} and user_id = #{rec.id}").order("id desc")}
  has_many :ip_bans, foreign_key: :creator_id
  has_many :tag_aliases, foreign_key: :creator_id
  has_many :tag_implications, foreign_key: :creator_id
  belongs_to :inviter, class_name: "User", optional: true

  enum theme: { light: 0, dark: 100 }, _suffix: true

  module BanMethods
    def validate_ip_addr_is_not_banned
      if IpBan.is_banned?(CurrentUser.ip_addr)
        errors[:base] << "IP address is banned"
      end
    end

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

      # XXX downcasing is the wrong way to do case-insensitive comparison for unicode (should use casefolding).
      def find_by_name(name)
        where_iequals(:name, normalize_name(name)).first
      end

      def normalize_name(name)
        name.to_s.mb_chars.downcase.strip.tr(" ", "_").to_s
      end
    end

    def pretty_name
      name.gsub(/([^_])_+(?=[^_])/, "\\1 \\2")
    end
  end

  module PasswordMethods
    def bcrypt_password
      BCrypt::Password.new(bcrypt_password_hash)
    end

    def bcrypt_cookie_password_hash
      bcrypt_password_hash.slice(20, 100)
    end

    def encrypt_password_on_create
      self.bcrypt_password_hash = User.bcrypt(password)
    end

    def encrypt_password_on_update
      return if password.blank?
      return if old_password.blank?

      if bcrypt_password == User.sha1(old_password)
        self.bcrypt_password_hash = User.bcrypt(password)
        return true
      else
        errors[:old_password] << "is incorrect"
        return false
      end
    end

    def reset_password
      consonants = "bcdfghjklmnpqrstvqxyz"
      vowels = "aeiou"
      pass = ""

      6.times do
        pass << consonants[rand(21), 1]
        pass << vowels[rand(5), 1]
      end

      pass << rand(100).to_s
      update_column(:bcrypt_password_hash, User.bcrypt(pass))
      pass
    end

    def reset_password_and_deliver_notice
      new_password = reset_password
      Maintenance::User::PasswordResetMailer.confirmation(self, new_password).deliver_now
    end
  end

  module AuthenticationMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def authenticate(name, pass)
        authenticate_hash(name, sha1(pass))
      end

      def authenticate_api_key(name, api_key)
        key = ApiKey.where(:key => api_key).first
        return nil if key.nil?
        user = find_by_name(name)
        return nil if user.nil?
        return user if key.user_id == user.id
        nil
      end

      def authenticate_hash(name, hash)
        user = find_by_name(name)
        if user && user.bcrypt_password == hash
          user
        else
          nil
        end
      end

      def authenticate_cookie_hash(name, hash)
        user = find_by_name(name)
        if user && user.bcrypt_cookie_password_hash == hash
          user
        else
          nil
        end
      end

      def bcrypt(pass)
        BCrypt::Password.create(sha1(pass))
      end

      def sha1(pass)
        salt = "choujin-steiner"
        Digest::SHA1.hexdigest("#{salt}--#{pass}--")
      end
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
        self.is_super_voter = true
      end
    end

    def customize_new_user
      Danbooru.config.customize_new_user(self)
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

    def is_voter?
      is_gold? || is_super_voter?
    end

    def is_approver?
      can_approve_posts?
    end

    def set_per_page
      if per_page.nil? || !is_gold?
        self.per_page = Danbooru.config.posts_per_page
      end
    end
  end

  module EmailMethods
    def normalize_email
      self.email = nil if email.blank?
    end
  end

  module BlacklistMethods
    def normalize_blacklisted_tags
      self.blacklisted_tags = blacklisted_tags.downcase if blacklisted_tags.present?
    end
  end

  module ForumMethods
    def has_forum_been_updated?
      return false unless is_gold?
      max_updated_at = ForumTopic.permitted.active.maximum(:updated_at)
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

    def can_comment?
      if is_gold?
        true
      else
        created_at <= Danbooru.config.member_comment_time_threshold
      end
    end

    def is_comment_limited?
      if is_gold?
        false
      else
        Comment.where("creator_id = ? and created_at > ?", id, 1.hour.ago).count >= Danbooru.config.member_comment_limit
      end
    end

    def can_comment_vote?
      CommentVote.where("user_id = ? and created_at > ?", id, 1.hour.ago).count < 10
    end

    def can_remove_from_pools?
      created_at <= 1.week.ago
    end

    def can_view_flagger?(flagger_id)
      is_moderator? || flagger_id == id
    end

    def can_view_flagger_on_post?(flag)
      (is_moderator? && flag.not_uploaded_by?(id)) || flag.creator_id == id
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
    def api_attributes
      attributes = %i[
        id created_at name inviter_id level
        post_upload_count post_update_count note_update_count is_banned
        can_approve_posts can_upload_free is_super_voter level_string
      ]

      if id == CurrentUser.user.id
        attributes += BOOLEAN_ATTRIBUTES
        attributes += %i[
          updated_at email last_logged_in_at last_forum_read_at
          comment_threshold default_image_size
          favorite_tags blacklisted_tags time_zone per_page
          custom_style favorite_count api_regen_multiplier
          api_burst_limit remaining_api_limit statement_timeout
          favorite_group_limit favorite_limit tag_query_limit
          can_comment_vote? can_remove_from_pools? is_comment_limited?
          can_comment? max_saved_searches theme
        ]
      end

      attributes
    end

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
      return nil unless PoolArchive.enabled?
      PoolArchive.for_user(id).count
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
      feedback.positive.count
    end

    def neutral_feedback_count
      feedback.neutral.count
    end

    def negative_feedback_count
      feedback.negative.count
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
    def admins
      where("level = ?", Levels::ADMIN)
    end

    # UserDeletion#rename renames deleted users to `user_<1234>~`. Tildes
    # are appended if the username is taken.
    def deleted
      where("name ~ 'user_[0-9]+~*'")
    end

    def undeleted
      where("name !~ 'user_[0-9]+~*'")
    end

    def with_email(email)
      if email.blank?
        where("FALSE")
      else
        where("email = ?", email)
      end
    end

    def search(params)
      q = super

      params = params.dup
      params[:name_matches] = params.delete(:name) if params[:name].present?

      q = q.search_attributes(params, :name, :level, :inviter, :post_upload_count, :post_update_count, :note_update_count, :favorite_count)

      if params[:name_matches].present?
        q = q.where_ilike(:name, normalize_name(params[:name_matches]))
      end

      if params[:min_level].present?
        q = q.where("level >= ?", params[:min_level].to_i)
      end

      if params[:max_level].present?
        q = q.where("level <= ?", params[:max_level].to_i)
      end

      %w[can_approve_posts can_upload_free is_super_voter].each do |flag|
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

  concerning :SockPuppetMethods do
    def validate_sock_puppets
      if User.where(last_ip_addr: CurrentUser.ip_addr).where("created_at > ?", 1.day.ago).exists?
        errors.add(:last_ip_addr, "was used recently for another account and cannot be reused for another day")
      end
    end
  end

  include BanMethods
  include PasswordMethods
  include AuthenticationMethods
  include LevelMethods
  include EmailMethods
  include BlacklistMethods
  include ForumMethods
  include LimitMethods
  include ApiMethods
  include CountMethods
  extend SearchMethods

  def as_current(&block)
    CurrentUser.as(self, &block)
  end

  def reportable_by?(user)
    ModerationReport.enabled? && user.is_builder? && id != user.id && !is_moderator?
  end

  def hide_favorites?
    !CurrentUser.is_admin? && enable_private_favorites? && CurrentUser.user.id != id
  end

  def initialize_attributes
    self.last_ip_addr ||= CurrentUser.ip_addr
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

  def self.available_includes
    [:inviter]
  end
end
