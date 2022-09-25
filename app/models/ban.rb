# frozen_string_literal: true

class Ban < ApplicationRecord
  attribute :duration, :interval

  after_create :create_feedback
  after_create :update_user_on_create
  after_create :create_ban_mod_action
  after_destroy :update_user_on_destroy
  after_destroy :create_unban_mod_action
  belongs_to :user
  belongs_to :banner, :class_name => "User"

  validates :reason, presence: true
  validate :user, :validate_user_is_bannable, on: :create

  scope :unexpired, -> { where("bans.created_at + bans.duration > ?", Time.zone.now) }
  scope :expired, -> { where("bans.created_at + bans.duration <= ?", Time.zone.now) }
  scope :active, -> { unexpired }

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :duration, :reason, :user, :banner], current_user: current_user)

    q = q.expired if params[:expired].to_s.truthy?
    q = q.unexpired if params[:expired].to_s.falsy?

    case params[:order]
    when "expires_at_desc"
      q = q.order(Arel.sql("bans.created_at + bans.duration DESC"))
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
    errors.add(:user, "is already banned") if user&.is_banned?
  end

  def update_user_on_create
    user.update!(is_banned: true)
  end

  def update_user_on_destroy
    user.update!(is_banned: false)
  end

  def user_name
    user ? user.name : nil
  end

  def user_name=(username)
    self.user = User.find_by_name(username)
  end

  def expires_at
    created_at + duration
  end

  def humanized_duration
    ApplicationController.helpers.humanized_duration(duration)
  end

  def forever?
    duration.present? && duration >= 100.years
  end

  def expired?
    persisted? && expires_at < Time.zone.now
  end

  def create_feedback
    user.feedback.create!(creator: banner, category: "negative", body: "Banned #{humanized_duration}: #{reason}")
  end

  def create_ban_mod_action
    ModAction.log(%{banned <@#{user_name}> #{humanized_duration}: #{reason}}, :user_ban, subject: user, user: banner)
  end

  def create_unban_mod_action
    ModAction.log(%{unbanned <@#{user_name}>}, :user_unban, subject: user, user: CurrentUser.user)
  end

  def self.available_includes
    [:user, :banner]
  end
end
