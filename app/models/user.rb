require 'digest/sha1'

class User < ActiveRecord::Base
  class Error < Exception ; end
  class PrivilegeError < Exception ; end
  
  attr_accessor :password, :old_password, :ip_addr
  attr_accessible :password, :old_password, :password_confirmation, :password_hash, :email, :last_logged_in_at, :last_forum_read_at, :has_mail, :receive_email_notifications, :comment_threshold, :always_resize_images, :favorite_tags, :blacklisted_tags, :name, :ip_addr
  validates_length_of :name, :within => 2..20, :on => :create
  validates_format_of :name, :with => /\A[^\s;,]+\Z/, :on => :create, :message => "cannot have whitespace, commas, or semicolons"
  validates_uniqueness_of :name, :case_sensitive => false, :on => :create
  validates_uniqueness_of :email, :case_sensitive => false, :on => :create, :if => lambda {|rec| !rec.email.blank?}
  validates_length_of :password, :minimum => 5, :if => lambda {|rec| rec.new_record? || !rec.password.blank?}
  validates_inclusion_of :default_image_size, :in => %w(medium large original)
  validates_confirmation_of :password
  validates_presence_of :email, :if => lambda {|rec| rec.new_record? && Danbooru.config.enable_email_verification?}
  validates_presence_of :ip_addr, :on => :create
  validate :validate_ip_addr_is_not_banned, :on => :create
  before_save :encrypt_password
  after_save :update_cache
  before_create :promote_to_admin_if_first_user
  before_create :normalize_level
  has_many :feedback, :class_name => "UserFeedback", :dependent => :destroy
  has_one :ban
  belongs_to :inviter, :class_name => "User"
  scope :named, lambda {|name| where(["lower(name) = ?", name])}
  scope :admins, where("is_admin = TRUE")
  
  module BanMethods
    def validate_ip_addr_is_not_banned
      if IpBan.is_banned?(ip_addr)
        self.errors[:base] << "IP address is banned"
        return false
      end
    end
    
    def unban!
      update_attribute(:is_banned, false)
      ban.destroy
    end
  end
  
  module NameMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def name_to_id(name)
        Cache.get("uni:#{Cache.sanitize(name)}") do
          select_value_sql("SELECT id FROM users WHERE lower(name) = ?", name.downcase)
        end
      end
      
      def id_to_name(user_id)
        Cache.get("uin:#{user_id}") do
          select_value_sql("SELECT name FROM users WHERE id = ?", user_id) || Danbooru.config.default_guest_name
        end
      end
      
      def find_by_name(name)
        where(["lower(name) = ?", name.downcase]).first
      end
      
      def id_to_pretty_name(user_id)
        id_to_name.tr("_", " ")
      end
    end
    
    def pretty_name
      name.tr("_", " ")
    end
    
    def update_cache
      Cache.put("uin:#{id}", name)
    end
  end
  
  module PasswordMethods
    def encrypt_password
      self.password_hash = self.class.sha1(password) if password
    end

    def reset_password
      consonants = "bcdfghjklmnpqrstvqxyz"
      vowels = "aeiou"
      pass = ""

      4.times do
        pass << consonants[rand(21), 1]
        pass << vowels[rand(5), 1]
      end

      pass << rand(100).to_s
      execute_sql("UPDATE users SET password_hash = ? WHERE id = ?", self.class.sha1(pass), id)
      pass    
    end
  end
  
  module AuthenticationMethods
    def authenticate(name, pass)
      authenticate_hash(name, sha1(pass))
    end

    def authenticate_hash(name, pass)
      where(["lower(name) = ? AND password_hash = ?", name.downcase, pass]).first != nil
    end

    def sha1(pass)
      Digest::SHA1.hexdigest("#{Danbooru.config.password_salt}--#{pass}--")
    end
  end
  
  module FavoriteMethods
    def favorite_posts(options = {})
      favorites_table = Favorite.table_name_for(id)
      if options[:before_id]
        before_id_sql_fragment = ["favorites.id < ?", options[:before_id]]
      else
        before_id_sql_fragment = "TRUE"
      end
      limit = options[:limit] || 20

      Post.joins("JOIN #{favorites_table} AS favorites ON favorites.post_id = posts.id").where("favorites.user_id = ?", id).where(before_id_sql_fragment).order("favorite_id DESC").limit(limit).select("posts.*, favorites.id AS favorite_id")
    end
  end
  
  module LevelMethods
    def promote_to_admin_if_first_user
      return if Rails.env.test?
      
      if User.count == 0
        self.is_admin = true
      end
    end
    
    def normalize_level
      if is_admin?
        self.is_moderator = true
        self.is_janitor = true
        self.is_contributor = true
        self.is_privileged = true
      elsif is_moderator?
        self.is_janitor = true
        self.is_privileged = true
      elsif is_janitor?
        self.is_privileged = true
      elsif is_contributor?
        self.is_privileged = true
      end
    end
    
    def is_anonymous?
      false
    end

    def is_member?
      true
    end
  end
  
  module EmailVerificationMethods
    def is_verified?
      email_verification_key.blank?
    end
    
    def generate_email_verification_key
      self.email_verification_key = Digest::SHA1.hexdigest("#{Time.now.to_f}--#{name}--#{rand(1_000_000)}--")
    end
    
    def verify!(key)
      if email_verification_key == key
        self.update_attribute(:email_verification_key, nil)
      else
        raise User::Error.new("Verification key does not match")
      end
    end
  end
  
  module BlacklistMethods
    def blacklisted_tag_array
      Tag.scan_query(blacklisted_tags)
    end
  end
  
  module ForumMethods
    def has_forum_been_updated?
      return false unless is_privileged?
      newest_topic = ForumPost.first(:order => "updated_at desc", :select => "updated_at")
      return false if newest_topic.nil?
      return newest_topic.updated_at > user.last_forum_read_at
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
      elsif created_at > 1.week.ago
        false
      else
        Comment.where("creator_id = ? and created_at > ?", id, 1.hour.ago).count <= Danbooru.config.member_comment_limit
      end      
    end
    
    def can_comment_vote?
      CommentVote.where("user_id = ? and created_at > ?", id, 1.hour.ago).count < 10
    end
    
    def can_remove_from_pools?
      created_at <= 1.week.ago
    end
    
    def upload_limit
      deleted_count = RemovedPost.where("user_id = ?", id).count
      unapproved_count = Post.where("is_pending = true and user_id = ?", id).count
      approved_count = Post.where("is_flagged = false and is_pending = false and user_id = ?", id).count
      
      limit = base_upload_limit + (approved_count / 10) - (deleted_count / 4) - unapproved_count
      
      if limit > 20
        limit = 20
      end
      
      if limit < 0
        limit = 0
      end
      
      limit
    end
  end
  
  include BanMethods
  include NameMethods
  include PasswordMethods
  extend AuthenticationMethods
  include FavoriteMethods
  include LevelMethods
  include EmailVerificationMethods
  include BlacklistMethods
  include ForumMethods
  include LimitMethods
  
  def initialize_default_image_size
    self.default_image_size = "Medium"
  end

  def can_update?(object, foreign_key = :user_id)
    is_moderator? || is_admin? || object.__send__(foreign_key) == id
  end
end

