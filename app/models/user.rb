require 'digest/sha1'

class User < ActiveRecord::Base
  class Error < Exception ; end
  class PrivilegeError < Exception ; end
  
  module Levels
    MEMBER = 20
    PRIVILEGED = 30
    BUILDER = 32
    CONTRIBUTOR = 33
    JANITOR = 35
    MODERATOR = 40
    ADMIN = 50
  end
  
  attr_accessor :password, :old_password
  attr_accessible :password, :old_password, :password_confirmation, :password_hash, :email, :last_logged_in_at, :last_forum_read_at, :has_mail, :receive_email_notifications, :comment_threshold, :always_resize_images, :favorite_tags, :blacklisted_tags, :name, :ip_addr, :time_zone, :default_image_size, :as => [:moderator, :janitor, :contributor, :privileged, :member, :anonymous, :default, :admin]
  attr_accessible :level, :as => :admin
  validates_length_of :name, :within => 2..100, :on => :create
  validates_format_of :name, :with => /\A[^\s:]+\Z/, :on => :create, :message => "cannot have whitespace or colons"
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :email, :case_sensitive => false, :if => lambda {|rec| rec.email.present?}
  validates_length_of :password, :minimum => 5, :if => lambda {|rec| rec.new_record? || rec.password.present?}
  validates_inclusion_of :default_image_size, :in => %w(large original)
  validates_confirmation_of :password
  validates_presence_of :email, :if => lambda {|rec| rec.new_record? && Danbooru.config.enable_email_verification?}
  validates_presence_of :comment_threshold
  validate :validate_ip_addr_is_not_banned, :on => :create
  validate :validate_feedback_on_name_change, :on => :update
  before_validation :normalize_blacklisted_tags
  before_create :encrypt_password_on_create
  before_update :encrypt_password_on_update
  after_save :update_cache
  after_update :update_remote_cache
  before_create :promote_to_admin_if_first_user
  has_many :feedback, :class_name => "UserFeedback", :dependent => :destroy
  has_many :posts, :foreign_key => "uploader_id"
  has_one :ban
  has_many :subscriptions, :class_name => "TagSubscription", :foreign_key => "creator_id"
  has_many :note_versions, :foreign_key => "updater_id"
  has_many :dmails, :foreign_key => "owner_id", :order => "dmails.id desc"
  belongs_to :inviter, :class_name => "User"
    
  module BanMethods
    def validate_ip_addr_is_not_banned
      if IpBan.is_banned?(CurrentUser.ip_addr)
        self.errors[:base] << "IP address is banned"
        return false
      end
    end
    
    def unban!
      update_column(:is_banned, false)
      ban.destroy
    end
  end
  
  module InvitationMethods
    def invite!(level)
      if level.to_i <= Levels::CONTRIBUTOR
        ModAction.create(:description => "invited user ##{id} (#{name})")
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
          select_value_sql("SELECT id FROM users WHERE lower(name) = ?", name.downcase)
        end
      end
      
      def id_to_name(user_id)
        Cache.get("uin:#{user_id}", 4.hours) do
          select_value_sql("SELECT name FROM users WHERE id = ?", user_id) || Danbooru.config.default_guest_name
        end
      end
      
      def find_by_name(name)
        where(["lower(name) = ?", name.downcase]).first
      end
      
      def id_to_pretty_name(user_id)
        id_to_name(user_id).tr("_", " ")
      end
    end
    
    def pretty_name
      name.tr("_", " ")
    end
    
    def update_cache
      Cache.put("uin:#{id}", name)
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
    
    def validate_feedback_on_name_change
      if feedback.negative.count > 0 && name_changed?
        self.errors[:base] << "You can not change your name if you have any negative feedback"
        return false
      end
    end
  end
  
  module PasswordMethods
    def encrypt_password_on_create
      self.password_hash = User.sha1(password)
    end
    
    def encrypt_password_on_update
      return if password.blank?
      return if old_password.blank?
      
      if User.sha1(old_password) == password_hash
        self.password_hash = User.sha1(password)
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
      update_column(:password_hash, User.sha1(pass))
      pass    
    end
    
    def reset_password_and_deliver_notice
      new_password = reset_password()
      Maintenance::User::PasswordResetMailer.confirmation(self, new_password).deliver
    end
  end
  
  module AuthenticationMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def authenticate(name, pass)
        authenticate_hash(name, sha1(pass))
      end

      def authenticate_hash(name, hash)
        where(["lower(name) = ? AND password_hash = ?", name.downcase, hash]).first != nil
      end
    
      def authenticate_cookie_hash(name, hash)
        user = User.find_by_name(name)
        return nil if user.nil?
        return hash == user.cookie_password_hash
      end

      def sha1(pass)
        Digest::SHA1.hexdigest("#{Danbooru.config.password_salt}--#{pass}--")
      end
    end

    def cookie_password_hash
      hash = password_hash
      
      (name.size + 8).times do
        hash = User.sha1(hash)
      end
      
      return hash
    end
  end
  
  module FavoriteMethods
    def favorites
      Favorite.where("user_id % 100 = #{id % 100} and user_id = #{id}").order("id desc")
    end
    
    def add_favorite!(post)
      return if Favorite.for_user(id).exists?(:user_id => id, :post_id => post.id)
      Favorite.create(:user_id => id, :post_id => post.id)
      increment!(:favorite_count)
      post.add_favorite!(self)
    end
    
    def remove_favorite!(post)
      return unless Favorite.for_user(id).exists?(:user_id => id, :post_id => post.id)
      Favorite.destroy_all(:user_id => id, :post_id => post.id)
      decrement!(:favorite_count)
      post.remove_favorite!(self)
    end
  end
  
  module LevelMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def level_hash
        return {
          "Member" => Levels::MEMBER,
          "Privileged" => Levels::PRIVILEGED,
          "Builder" => Levels::BUILDER,
          "Contributor" => Levels::CONTRIBUTOR,
          "Janitor" => Levels::JANITOR,
          "Moderator" => Levels::MODERATOR,
          "Admin" => Levels::ADMIN
        }
      end
    end
    
    def promote_to_admin_if_first_user
      return if Rails.env.test?
      
      if User.count == 0
        self.level = Levels::ADMIN
      end
    end
    
    def role
      case level
      when Levels::MEMBER, Levels::PRIVILEGED, Levels::BUILDER, Levels::CONTRIBUTOR
        :member
        
      when Levels::MODERATOR, Levels::JANITOR
        :moderator
        
      when Levels::ADMIN
        :admin
      end
    end
    
    def level_string
      case level
      when Levels::MEMBER
        "Member"
        
      when Levels::BUILDER
        "Builder"
        
      when Levels::PRIVILEGED
        "Privileged"
        
      when Levels::CONTRIBUTOR
        "Contributor"
        
      when Levels::JANITOR
        "Janitor"
        
      when Levels::MODERATOR
        "Moderator"
        
      when Levels::ADMIN
        "Admin"
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
    
    def is_privileged?
      level >= Levels::PRIVILEGED
    end
    
    def is_contributor?
      level >= Levels::CONTRIBUTOR
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
      return false unless is_privileged?
      newest_topic = ForumPost.order("updated_at desc").first
      return false if newest_topic.nil?
      return true if last_forum_read_at.nil?
      return newest_topic.updated_at > last_forum_read_at
    end
  end
  
  module LimitMethods
    def can_upload?
      if is_contributor?
        true
      elsif created_at > 1.week.ago
        false
      else
        upload_limit > 0
      end
    end
    
    def can_comment?
      if is_privileged?
        true
      elsif created_at > Danbooru.config.member_comment_time_threshold
        false
      else
        Comment.where("creator_id = ? and created_at > ?", id, 1.hour.ago).count < Danbooru.config.member_comment_limit
      end
    end
    
    def can_comment_vote?
      CommentVote.where("user_id = ? and created_at > ?", id, 1.hour.ago).count < 10
    end
    
    def can_remove_from_pools?
      created_at <= 1.week.ago
    end
    
    def upload_limit
      deleted_count = Post.for_user(id).deleted.count
      pending_count = Post.for_user(id).pending.count
      approved_count = Post.where("is_flagged = false and is_pending = false and uploader_id = ?", id).count
      
      if base_upload_limit
        limit = base_upload_limit - pending_count
      else
        limit = 10 + (approved_count / 10) - (deleted_count / 4) - pending_count
      end
      
      if limit > 20
        limit = 20
      end
      
      if limit < 0
        limit = 0
      end
      
      limit
    end
  end
  
  module ApiMethods
    def hidden_attributes
      super + [:password_hash, :email, :email_verification_key]
    end
    
    def serializable_hash(options = {})
      options ||= {}
      options[:except] ||= []
      options[:except] += hidden_attributes
      super(options)
    end
    
    def to_xml(options = {}, &block)
      # to_xml ignores the serializable_hash method
      options ||= {}
      options[:except] ||= []
      options[:except] += hidden_attributes
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
  
  module SearchMethods
    def named(name)
      where("lower(name) = ?", name)
    end
    
    def name_matches(name)
      where("lower(name) like ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end
    
    def admins
      where("is_admin = TRUE")
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
      q = scoped
      return q if params.blank?
      
      if params[:name]
        q = q.name_matches(params[:name].downcase)
      end
      
      if params[:name_matches]
        q = q.name_matches(params[:name_matches].downcase)
      end
      
      if params[:min_level]
        q = q.where("level >= ?", params[:min_level].to_i)
      end
      
      if params[:id]
        q = q.where("id = ?", params[:id].to_i)
      end
      
      q
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
  extend SearchMethods
  
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
end

