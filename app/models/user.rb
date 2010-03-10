require 'digest/sha1'

class User < ActiveRecord::Base
  class Error < Exception ; end
  
  attr_accessor :password
  attr_accessible :password_hash, :email, :last_logged_in_at, :last_forum_read_at, :has_mail, :receive_email_notifications, :comment_threshold, :always_resize_images, :favorite_tags, :blacklisted_tags
  validates_length_of :name, :within => 2..20, :on => :create
  validates_format_of :name, :with => /\A[^\s;,]+\Z/, :on => :create, :message => "cannot have whitespace, commas, or semicolons"
  validates_uniqueness_of :name, :case_sensitive => false, :on => :create
  validates_uniqueness_of :email, :case_sensitive => false, :on => :create, :if => lambda {|rec| !rec.email.blank?}
  validates_length_of :password, :minimum => 5, :if => lambda {|rec| rec.password}
  validates_inclusion_of :default_image_size, :in => %w(medium large original)
  validates_confirmation_of :password
  before_save :encrypt_password
  after_save :update_cache
  before_create :normalize_level
  has_many :feedback, :class_name => "UserFeedback", :dependent => :destroy
  belongs_to :inviter, :class_name => "User"
  scope :named, lambda {|name| where(["lower(name) = ?", name])}  
  
  module NameMethods
    module ClassMethods
      def find_name(user_id)
        Cache.get("un:#{user_id}") do
          select_value_sql("SELECT name FROM users WHERE id = ?", user_id) || Danbooru.config.default_guest_name
        end
      end
      
      def find_pretty_name(user_id)
        find_name.tr("_", " ")
      end
    end
    
    def self.included(m)
      m.extend(ClassMethods)
    end

    def pretty_name
      name.tr("_", " ")
    end
    
    def update_cache
      Cache.put("un:#{id}", name)
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
      favorites_table = Favorite.table_name_for(self)
      before_id = options[:before]
      before_id_sql_fragment = "AND favorites.id < #{before_id.to_i}" if before_id
      limit = options[:limit] || 20
      
      sql = <<-EOS
        SELECT posts.*, favorites.id AS favorite_id
        FROM posts
        JOIN #{favorites_table} AS favorites ON favorites.post_id = posts.id
        WHERE
          favorites.user_id = #{id}
          #{before_id_sql_fragment}
        ORDER BY favorite_id DESC
        LIMIT #{limit.to_i}
      EOS
      Post.find_by_sql(sql)
    end
  end
  
  module LevelMethods
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
  
  include NameMethods
  include PasswordMethods
  extend AuthenticationMethods
  include FavoriteMethods
  include LevelMethods
  include EmailVerificationMethods
  include BlacklistMethods

  def can_update?(object, foreign_key = :user_id)
    is_moderator? || is_admin? || object.__send__(foreign_key) == id
  end
end

