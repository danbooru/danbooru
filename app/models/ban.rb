class Ban < ApplicationRecord
  after_create :create_feedback
  after_create :update_user_on_create
  after_create :create_ban_mod_action
  after_destroy :update_user_on_destroy
  after_destroy :create_unban_mod_action
  belongs_to :user
  belongs_to :banner, :class_name => "User"

  validates_presence_of :reason, :duration
  validate :user, :validate_user_is_bannable, on: :create

  scope :unexpired, -> { where("bans.expires_at > ?", Time.now) }
  scope :expired, -> { where("bans.expires_at <= ?", Time.now) }

  attr_reader :duration

  def self.is_banned?(user)
    exists?(["user_id = ? AND expires_at > ?", user.id, Time.now])
  end

  def self.search(params)
    q = super

    q = q.search_attributes(params, :expires_at, :reason)
    q = q.text_attribute_matches(:reason, params[:reason_matches])

    q = q.expired if params[:expired].to_s.truthy?
    q = q.unexpired if params[:expired].to_s.falsy?

    case params[:order]
    when "expires_at_desc"
      q = q.order("bans.expires_at desc")
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def self.prune!
    expired.includes(:user).find_each do |ban|
      ban.user.unban! if ban.user.ban_expired?
    end
  end

  def validate_user_is_bannable
    self.errors[:user] << "is already banned" if user.is_banned?
  end

  def update_user_on_create
    user.update!(is_banned: true)
  end

  def update_user_on_destroy
    user.update_attribute(:is_banned, false)
  end

  def user_name
    user ? user.name : nil
  end

  def user_name=(username)
    self.user = User.find_by_name(username)
  end

  def duration=(dur)
    self.expires_at = dur.to_i.days.from_now
    @duration = dur
  end

  def humanized_duration
    ApplicationController.helpers.distance_of_time_in_words(created_at, expires_at)
  end

  def expired?
    persisted? && expires_at < Time.now
  end

  def create_feedback
    user.feedback.create!(creator: banner, category: "negative", body: "Banned for #{humanized_duration}: #{reason}")
  end

  def create_ban_mod_action
    ModAction.log(%{Banned <@#{user_name}> for #{humanized_duration}: #{reason}}, :user_ban)
  end

  def create_unban_mod_action
    ModAction.log(%{Unbanned <@#{user_name}>}, :user_unban)
  end

  def self.searchable_includes
    [:user, :banner]
  end

  def self.available_includes
    [:user, :banner]
  end
end
