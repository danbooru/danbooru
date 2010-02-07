require 'digest/sha1'

class User < ActiveRecord::Base
  attr_accessor :password
  
  attr_accessible :password_hash, :email, :last_logged_in_at, :last_forum_read_at, :has_mail, :receive_email_notifications, :comment_threshold, :always_resize_images, :favorite_tags, :blacklisted_tags
  
  validates_length_of :name, :within => 2..20, :on => :create
  validates_format_of :name, :with => /\A[^\s;,]+\Z/, :on => :create, :message => "cannot have whitespace, commas, or semicolons"
  validates_uniqueness_of :name, :case_sensitive => false, :on => :create
  validates_uniqueness_of :email, :case_sensitive => false, :on => :create, :if => lambda {|rec| !rec.email.blank?}
  validates_length_of :password, :minimum => 5, :if => lambda {|rec| rec.password}
  validates_confirmation_of :password

  before_save :encrypt_password
  after_save {|rec| Cache.put("user_name:#{rec.id}", rec.name)}

  scope :named, lambda {|name| where(["lower(name) = ?", name])}  
  
  def can_update?(object, foreign_key = :user_id)
    is_moderator? || is_admin? || object.__send__(foreign_key) == id
  end
  
  ### Name Methods ###
  def self.find_name(user_id)
    Cache.get("user_name:#{user_id}") do
      select_value_sql("SELECT name FROM users WHERE id = ?", user_id) || Danbooru.config.default_guest_name
    end
  end

  def pretty_name
    name.tr("_", " ")
  end
  
  ### Password Methods ###
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
  
  ### Authentication Methods ###
  def self.authenticate(name, pass)
    authenticate_hash(name, sha1(pass))
  end

  def self.authenticate_hash(name, pass)
    where(["lower(name) = ? AND password_hash = ?", name.downcase, pass]).first != nil
  end

  def self.sha1(pass)
    Digest::SHA1.hexdigest("#{Danbooru.config.password_salt}--#{pass}--")
  end
end

