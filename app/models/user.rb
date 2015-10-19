require 'digest/sha1'
require 'danbooru/has_bit_flags'

class User < ActiveRecord::Base
  class Error < Exception ; end
  class PrivilegeError < Exception ; end

  module Levels
    BLOCKED = 10
    MEMBER = 20
    GOLD = 30
    PLATINUM = 31
    BUILDER = 32
    JANITOR = 35
    MODERATOR = 40
    ADMIN = 50
  end

  BOOLEAN_ATTRIBUTES = %w(
    is_banned
    has_mail
    receive_email_notifications
    always_resize_images
    enable_post_navigation
    new_post_navigation_layout
    enable_privacy_mode
    enable_sequential_post_navigation
    hide_deleted_posts
    style_usernames
    enable_auto_complete
    show_deleted_children
    has_saved_searches
    can_approve_posts
    can_upload_free
  )

  include Danbooru::HasBitFlags
  has_bit_flags BOOLEAN_ATTRIBUTES, :field => "bit_prefs"

  attr_accessor :password, :old_password
  attr_accessible :dmail_filter_attributes, :enable_privacy_mode, :enable_post_navigation, :new_post_navigation_layout, :password, :old_password, :password_confirmation, :password_hash, :email, :last_logged_in_at, :last_forum_read_at, :has_mail, :receive_email_notifications, :comment_threshold, :always_resize_images, :favorite_tags, :blacklisted_tags, :name, :ip_addr, :time_zone, :default_image_size, :enable_sequential_post_navigation, :per_page, :hide_deleted_posts, :style_usernames, :enable_auto_complete, :custom_style, :show_deleted_children, :as => [:moderator, :janitor, :gold, :member, :anonymous, :default, :builder, :admin]
  attr_accessible :level, :as => :admin
  validates_length_of :name, :within => 2..100, :on => :create
  validates_format_of :name, :with => /\A[^\s:]+\Z/, :on => :create, :message => "cannot have whitespace or colons"
  validates_format_of :name, :with => /\A[^_].*[^_]\Z/, :on => :create, :message => "cannot begin or end with an underscore"
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :email, :case_sensitive => false, :if => lambda {|rec| rec.email.present? && rec.email_changed? }
  validates_length_of :password, :minimum => 5, :if => lambda {|rec| rec.new_record? || rec.password.present?}
  validates_inclusion_of :default_image_size, :in => %w(large original)
  validates_inclusion_of :per_page, :in => 1..100
  validates_confirmation_of :password
  validates_presence_of :email, :if => lambda {|rec| rec.new_record? && Danbooru.config.enable_email_verification?}
  validates_presence_of :comment_threshold
  validate :validate_ip_addr_is_not_banned, :on => :create
  before_validation :normalize_blacklisted_tags
  before_validation :set_per_page
  before_create :encrypt_password_on_create
  before_update :encrypt_password_on_update
  before_create :initialize_default_boolean_attributes
  after_save :update_cache
  after_update :update_remote_cache
  before_create :promote_to_admin_if_first_user
  has_many :feedback, :class_name => "UserFeedback", :dependent => :destroy
  has_many :posts, :foreign_key => "uploader_id"
  has_many :bans, lambda {order("bans.id desc")}
  has_one :recent_ban, lambda {order("bans.id desc")}, :class_name => "Ban"
  has_one :api_key
  has_one :dmail_filter
  has_many :subscriptions, lambda {order("tag_subscriptions.name")}, :class_name => "TagSubscription", :foreign_key => "creator_id"
  has_many :note_versions, :foreign_key => "updater_id"
  has_many :dmails, lambda {order("dmails.id desc")}, :foreign_key => "owner_id"
  has_many :saved_searches
  belongs_to :inviter, :class_name => "User"
  after_update :create_mod_action
  accepts_nested_attributes_for :dmail_filter

  module BanMethods
    def validate_ip_addr_is_not_banned
      if IpBan.is_banned?(CurrentUser.ip_addr)
        self.errors[:base] << "IP address is banned"
        return false
      end
    end

    def unban!
      self.is_banned = false
      save
      ban.destroy
    end
  end

  module InvitationMethods
    def invite!(level, can_upload_free)
      if can_upload_free
        self.can_upload_free = true
      else
        self.can_upload_free = false
      end

      if level.to_i <= Levels::BUILDER
        self.level = level
        self.inviter_id = CurrentUser.id
        save
      end
    end
  end

  module NameMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def name_to_id(name)
        Cache.get("uni:#{Cache.sanitize(name)}", 4.hours) do
          select_value_sql("SELECT id FROM users WHERE lower(name) = ?", name.mb_chars.downcase.tr(" ", "_").to_s)
        end
      end

      def id_to_name(user_id)
        Cache.get("uin:#{user_id}", 4.hours) do
          select_value_sql("SELECT name FROM users WHERE id = ?", user_id) || Danbooru.config.default_guest_name
        end
      end

      def find_by_name(name)
        where("lower(name) = ?", name.mb_chars.downcase.tr(" ", "_")).first
      end

      def id_to_pretty_name(user_id)
        id_to_name(user_id).gsub(/([^_])_+(?=[^_])/, "\\1 \\2")
      end
    end

    def pretty_name
      name.gsub(/([^_])_+(?=[^_])/, "\\1 \\2")
    end

    def update_cache
      Cache.put("uin:#{id}", name)
      Cache.put("uni:#{Cache.sanitize(name)}", id)
    end

    def update_remote_cache
      if name_changed?
        Danbooru.config.other_server_hosts.each do |server|
          Net::HTTP.delete(URI.parse("http://#{server}/users/#{id}/cache"))
        end
      end
    rescue Exception
      # swallow, since it'll be expired eventually anyway
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
      self.password_hash = ""
      self.bcrypt_password_hash = User.bcrypt(password)
    end

    def encrypt_password_on_update
      return if password.blank?
      return if old_password.blank?

      if bcrypt_password == User.sha1(old_password)
        self.bcrypt_password_hash = User.bcrypt(password)
        return true
      else
        errors[:old_password] = "is incorrect"
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
      new_password = reset_password()
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
        Digest::SHA1.hexdigest("#{Danbooru.config.password_salt}--#{pass}--")
      end
    end
  end

  module FavoriteMethods
    def favorites
      Favorite.where("user_id % 100 = #{id % 100} and user_id = #{id}").order("id desc")
    end

    def clean_favorite_count?
      favorite_count < 0 || Kernel.rand(100) < [Math.log(favorite_count, 2), 5].min
    end

    def clean_favorite_count!
      update_column(:favorite_count, Favorite.for_user(id).count)
    end

    def add_favorite!(post)
      Favorite.add(post, self)
      clean_favorite_count! if clean_favorite_count?
    end

    def remove_favorite!(post)
      Favorite.remove(post, self)
    end

    def favorite_groups
      FavoriteGroup.for_creator(CurrentUser.user.id).order("updated_at desc")
    end
  end

  module LevelMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def level_hash
        return {
          "Member" => Levels::MEMBER,
          "Gold" => Levels::GOLD,
          "Platinum" => Levels::PLATINUM,
          "Builder" => Levels::BUILDER,
          "Janitor" => Levels::JANITOR,
          "Moderator" => Levels::MODERATOR,
          "Admin" => Levels::ADMIN
        }
      end
    end

    def promote_to!(new_level, options = {})
      UserPromotion.new(self, CurrentUser.user, new_level, options).promote!
    end

    def promote_to_admin_if_first_user
      return if Rails.env.test?

      if User.count == 0
        self.level = Levels::ADMIN
      else
        self.level = Levels::MEMBER
      end
    end

    def role
      case level
      when Levels::MEMBER
        :member

      when Levels::GOLD
        :gold

      when Levels::BUILDER
        :builder

      when Levels::MODERATOR
        :moderator

      when Levels::JANITOR
        :janitor

      when Levels::ADMIN
        :admin
      end
    end

    def level_string_was
      level_string(level_was)
    end

    def level_string(value = nil)
      case (value || level)
      when Levels::BLOCKED
        "Banned"

      when Levels::MEMBER
        "Member"

      when Levels::BUILDER
        "Builder"

      when Levels::GOLD
        "Gold"

      when Levels::PLATINUM
        "Platinum"

      when Levels::JANITOR
        "Janitor"

      when Levels::MODERATOR
        "Moderator"

      when Levels::ADMIN
        "Admin"
        
      else
        ""
      end
    end

    def is_anonymous?
      false
    end

    def is_member?
      true
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

    def is_janitor?
      level >= Levels::JANITOR
    end

    def is_moderator?
      level >= Levels::MODERATOR
    end

    def is_mod?
      level >= Levels::MODERATOR
    end

    def is_admin?
      level >= Levels::ADMIN
    end

    def create_mod_action
      if level_changed?
        ModAction.create(:description => %{"#{name}":/users/#{id} level changed #{level_string_was} -> #{level_string}})
      end
    end
    
    def set_per_page
      if per_page.nil? || !is_gold?
        self.per_page = Danbooru.config.posts_per_page
      end
      
      return true
    end

    def level_class
      "user-#{level_string.downcase}"
    end
  end

  module EmailMethods
    def is_verified?
      email_verification_key.blank?
    end

    def generate_email_verification_key
      self.email_verification_key = Digest::SHA1.hexdigest("#{Time.now.to_f}--#{name}--#{rand(1_000_000)}--")
    end

    def verify!(key)
      if email_verification_key == key
        self.update_column(:email_verification_key, nil)
      else
        raise User::Error.new("Verification key does not match")
      end
    end
  end

  module BlacklistMethods
    def blacklisted_tag_array
      Tag.scan_query(blacklisted_tags)
    end

    def normalize_blacklisted_tags
      self.blacklisted_tags = blacklisted_tags.downcase if blacklisted_tags.present?
    end
  end

  module ForumMethods
    def has_forum_been_updated?
      return false unless is_gold?
      max_updated_at = ForumTopic.active.maximum(:updated_at)
      return false if max_updated_at.nil?
      return true if last_forum_read_at.nil?
      return max_updated_at > last_forum_read_at
    end
  end

  module LimitMethods
    def max_saved_searches
      if is_platinum?
        2000
      elsif is_gold?
        200
      else
        1000
      end
    end

    def show_saved_searches?
      true
    end

    def can_upload?
      if can_upload_free?
        true
      elsif created_at > 1.minute.ago
        false
      else
        upload_limit > 0
      end
    end

    def upload_limited_reason
      if created_at > 1.minute.ago
        "cannot upload during your first minute of registration"
      else
        "have reached your upload limit for the day"
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

    def base_upload_limit
      if created_at >= 1.month.ago
        100
      elsif created_at >= 2.months.ago
        200
      elsif created_at >= 3.months.ago
        300
      elsif created_at >= 4.months.ago
        400
      else
        500
      end
    end

    def max_upload_limit
      dcon = [deletion_confidence(120), 15].min
      [(base_upload_limit * (1 - (dcon / 15.0))).ceil, 10].max
    end

    def upload_limit
      @upload_limit ||= begin
        uploaded_count = Post.for_user(id).where("created_at >= ?", 24.hours.ago).count
        uploaded_comic_count = Post.for_user(id).tag_match("comic").where("created_at >= ?", 24.hours.ago).count / 3
        limit = max_upload_limit - (uploaded_count - uploaded_comic_count)

        if limit < 0
          limit = 0
        end

        limit
      end
    end

    def tag_query_limit
      if is_platinum?
        Danbooru.config.base_tag_query_limit * 2
      elsif is_gold?
        Danbooru.config.base_tag_query_limit
      else
        Danbooru.config.base_tag_query_limit * 2
      end
    end

    def favorite_limit
      if is_platinum?
        nil
      elsif is_gold?
        20_000
      else
        nil
      end
    end

    def favorite_group_limit
      if is_platinum?
        10
      elsif is_gold?
        5
      else
        10
      end
    end

    def api_hourly_limit
      if is_platinum? && api_key.present?
        20_000
      elsif is_gold? && api_key.present?
        10_000
      else
        3_000
      end
    end

    def remaining_api_hourly_limit
      ApiLimiter.remaining_hourly_limit(CurrentUser.ip_addr)
    end
    
    def statement_timeout
      if is_platinum?
        9_000
      elsif is_gold?
        6_000
      else
        9_000
      end
    end
  end

  module ApiMethods
    def hidden_attributes
      super + [:password_hash, :bcrypt_password_hash, :email, :email_verification_key, :time_zone, :updated_at, :receive_email_notifications, :last_logged_in_at, :last_forum_read_at, :has_mail, :default_image_size, :comment_threshold, :always_resize_images, :favorite_tags, :blacklisted_tags, :recent_tags, :enable_privacy_mode, :enable_post_navigation, :new_post_navigation_layout, :enable_sequential_post_navigation, :hide_deleted_posts, :per_page, :style_usernames, :enable_auto_complete, :custom_style, :show_deleted_children, :has_saved_searches]
    end

    def method_attributes
      list = [:is_banned, :level_string]
      if id == CurrentUser.user.id
        list += [:remaining_api_hourly_limit]
      end
      list
    end

    def serializable_hash(options = {})
      options ||= {}
      options[:except] ||= []
      options[:except] += hidden_attributes
      options[:methods] ||= []
      options[:methods] += method_attributes
      super(options)
    end

    def to_xml(options = {}, &block)
      # to_xml ignores the serializable_hash method
      options ||= {}
      options[:except] ||= []
      options[:except] += hidden_attributes
      options[:methods] ||= []
      options[:methods] += method_attributes
      super(options, &block)
    end

    def to_legacy_json
      return {
        "name" => name,
        "id" => id,
        "level" => level,
        "created_at" => created_at.strftime("%Y-%m-%d %H:%M")
      }.to_json
    end
  end

  module CountMethods
    def wiki_page_version_count
      WikiPageVersion.for_user(id).count
    end

    def artist_version_count
      ArtistVersion.for_user(id).count
    end

    def artist_commentary_version_count
      ArtistCommentaryVersion.for_user(id).count
    end

    def pool_version_count
      PoolVersion.for_user(id).count
    end

    def forum_post_count
      ForumPost.for_user(id).count
    end

    def comment_count
      Comment.for_creator(id).count
    end

    def favorite_group_count
      FavoriteGroup.for_creator(id).count
    end

    def appeal_count
      PostAppeal.for_creator(id).count
    end

    def flag_count
      PostFlag.for_creator(id).count
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
  end

  module SearchMethods
    def named(name)
      where("lower(name) = ?", name)
    end

    def name_matches(name)
      where("lower(name) like ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end

    def admins
      where("level = ?", Levels::ADMIN)
    end

    def with_email(email)
      if email.blank?
        where("FALSE")
      else
        where("email = ?", email)
      end
    end

    def find_for_password_reset(name, email)
      if email.blank?
        where("FALSE")
      else
        where(["name = ? AND email = ?", name, email])
      end
    end

    def search(params)
      q = where("true")
      return q if params.blank?

      if params[:name].present?
        q = q.name_matches(params[:name].mb_chars.downcase.strip.tr(" ", "_"))
      end

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches].mb_chars.downcase.strip.tr(" ", "_"))
      end

      if params[:min_level].present?
        q = q.where("level >= ?", params[:min_level].to_i)
      end

      if params[:max_level].present?
        q = q.where("level <= ?", params[:max_level].to_i)
      end

      if params[:level].present?
        q = q.where("level = ?", params[:level].to_i)
      end

      if params[:id].present?
        q = q.where("id in (?)", params[:id].split(",").map(&:to_i))
      end

      if params[:current_user_first] == "true" && !CurrentUser.is_anonymous?
        q = q.order("id = #{CurrentUser.user.id.to_i} desc")
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
        q = q.order("created_at desc")
      end

      q
    end
  end

  module StatisticsMethods
    def deletion_confidence(days = 30)
      Reports::UserPromotions.deletion_confidence_interval_for(self, days)
    end
  end

  include BanMethods
  include NameMethods
  include PasswordMethods
  include AuthenticationMethods
  include FavoriteMethods
  include LevelMethods
  include EmailMethods
  include BlacklistMethods
  include ForumMethods
  include LimitMethods
  include InvitationMethods
  include ApiMethods
  include CountMethods
  extend SearchMethods
  include StatisticsMethods

  def initialize_default_image_size
    self.default_image_size = "large"
  end

  def can_update?(object, foreign_key = :user_id)
    is_moderator? || is_admin? || object.__send__(foreign_key) == id
  end

  def dmail_count
    if has_mail?
      "(#{dmails.unread.count})"
    else
      ""
    end
  end

  def initialize_default_boolean_attributes
    self.enable_post_navigation = true
    self.new_post_navigation_layout = true
    self.enable_sequential_post_navigation = true
    self.enable_auto_complete = true
  end
end
