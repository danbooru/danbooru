# frozen_string_literal: true

class NewsUpdate < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :updater, class_name: "User", default: -> { creator }
  has_many :mod_actions, as: :subject, dependent: :destroy

  deletable
  dtext_attribute :message, inline: true

  scope :active, -> { undeleted.where("created_at + duration >= ?", Time.zone.now) }

  normalizes :message, with: ->(message) { message.to_s.normalize_whitespace.unicode_normalize(:nfc).strip }
  validate :validate_duration, if: :duration_changed?
  validate :validate_active, on: :create
  validates :message, presence: true, length: { maximum: 280 }, if: :message_changed?

  after_save :create_mod_action

  def self.visible(user)
    if user.is_admin?
      all
    else
      none
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :message, :creator, :updater], current_user: current_user)
    q.apply_default_order(params)
  end

  def duration_in_days=(days)
    self.duration = days.to_i.days
  end

  def validate_active
    errors.add(:base, "Can't have more than one active news update at a time") if NewsUpdate.active.exists?
  end

  def validate_duration
    errors.add(:duration, "must be between 1 and 30 days") unless Array(1..30).map(&:days).include?(duration)
  end

  def create_mod_action
    if previously_new_record?
      ModAction.log("created news update ##{id}", :news_update_create, subject: self, user: updater)
    elsif saved_change_to_message?
      ModAction.log("updated news update ##{id}", :news_update_update, subject: self, user: updater)
    elsif is_deleted? == true && is_deleted_before_last_save == false
      ModAction.log("deleted news update ##{id}", :news_update_delete, subject: self, user: updater)
    elsif is_deleted? == false && is_deleted_before_last_save == true
      ModAction.log("undeleted news update ##{id}", :news_update_undelete, subject: self, user: updater)
    end
  end

  def status
    flags = []

    flags << "Expired" if expired?
    flags << "Deleted" if is_deleted

    flags << "Active" if flags.empty?

    flags.join(", ")
  end

  def expired?
    expired_at < Time.zone.now
  end

  def expired_at
    created_at + duration
  end
end
