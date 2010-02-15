require 'digest/sha1'

class User < ActiveRecord::Base
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
  scope :named, lambda {|name| where(["lower(name) = ?", name])}  
  
  module NameMethods
    module ClassMethods
      def find_name(user_id)
        Cache.get("un:#{user_id}") do
          select_value_sql("SELECT name FROM users WHERE id = ?", user_id) || Danbooru.config.default_guest_name
        end
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
  
  include NameMethods
  include PasswordMethods
  extend AuthenticationMethods
  include FavoriteMethods

  def can_update?(object, foreign_key = :user_id)
    is_moderator? || is_admin? || object.__send__(foreign_key) == id
  end
end

