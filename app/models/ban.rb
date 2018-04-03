class Ban < ApplicationRecord
  after_create :create_feedback
  after_create :update_user_on_create
  after_create :create_mod_action
  after_destroy :update_user_on_destroy
  belongs_to :user
  belongs_to :banner, :class_name => "User"
  validate :user_is_inferior
  validates_presence_of :user_id, :reason, :duration
  before_validation :initialize_banner_id, :on => :create

  scope :unexpired, -> { where("bans.expires_at > ?", Time.now) }
  scope :expired, -> { where("bans.expires_at <= ?", Time.now) }

  def self.is_banned?(user)
    exists?(["user_id = ? AND expires_at > ?", user.id, Time.now])
  end

  def self.reason_matches(query)
    if query =~ /\*/
      where("lower(bans.reason) LIKE ?", query.mb_chars.downcase.to_escaped_for_sql_like)
    else
      where("bans.reason @@ plainto_tsquery(?)", query)
    end
  end

  def self.search(params)
    q = super

    if params[:banner_name]
      q = q.where("banner_id = (select _.id from users _ where lower(_.name) = ?)", params[:banner_name].mb_chars.downcase)
    end

    if params[:banner_id]
      q = q.where("banner_id = ?", params[:banner_id].to_i)
    end

    if params[:user_name]
      q = q.where("user_id = (select _.id from users _ where lower(_.name) = ?)", params[:user_name].mb_chars.downcase)
    end

    if params[:user_id]
      q = q.where("user_id = ?", params[:user_id].to_i)
    end

    if params[:reason_matches].present?
      q = q.reason_matches(params[:reason_matches])
    end

    case params[:expired]
    when "true"  then q = q.expired
    when "false" then q = q.unexpired
    end

    case params[:order]
    when "expires_at_desc"
      q = q.order("bans.expires_at desc")
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def initialize_banner_id
    self.banner_id = CurrentUser.id if self.banner_id.blank?
  end

  def user_is_inferior
    if user
      if user.is_admin?
        errors[:base] << "You can never ban an admin."
        false
      elsif user.is_moderator? && banner.is_admin?
        true
      elsif user.is_moderator?
        errors[:base] << "Only admins can ban moderators."
        false
      elsif banner.is_admin? || banner.is_moderator?
        true
      else
        errors[:base] << "No one else can ban."
        false
      end
    end
  end

  def update_user_on_create
    user.update_attribute(:is_banned, true)
  end

  def update_user_on_destroy
    user.update_attribute(:is_banned, false)
  end

  def user_name
    user ? user.name : nil
  end

  def user_name=(username)
    self.user_id = User.name_to_id(username)
  end

  def duration=(dur)
    self.expires_at = dur.to_i.days.from_now
    @duration = dur
  end

  def duration
    @duration
  end

  def humanized_duration
    ApplicationController.helpers.distance_of_time_in_words(created_at, expires_at)
  end

  def expired?
    expires_at < Time.now
  end

  def create_feedback
    user.feedback.create(category: "negative", body: "Banned for #{humanized_duration}: #{reason}")
  end

  def create_mod_action
    ModAction.log(%{Banned <@#{user_name}> for #{humanized_duration}: #{reason}},:user_ban)
  end
end
