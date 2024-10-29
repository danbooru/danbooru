# frozen_string_literal: true

class NewsUpdate < ApplicationRecord
  attr_accessor :duration_in_days

  belongs_to :creator, class_name: "User"
  belongs_to_updater

  deletable
  scope :active, -> { undeleted.where("created_at + duration >= ?", Time.zone.now) }

  before_validation :parse_duration_in_days
  validate :validate_duration, if: :duration_changed?
  validates :message, presence: true, if: :message_changed?

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

  def parse_duration_in_days
    self.duration = duration_in_days.to_i.days if duration_in_days.present?
  end

  def validate_duration
    errors.add(:duration, "must be between 1 and 30 days") unless Array(1..30).map(&:days).include?(duration)
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
