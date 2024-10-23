# frozen_string_literal: true

class NewsUpdate < ApplicationRecord
  attr_accessor :duration_in_days

  belongs_to :creator, class_name: "User"
  belongs_to_updater

  deletable
  scope :active, -> { undeleted.where("created_at + duration >= ?", Time.zone.now) }

  validates :duration, inclusion: { in: Array(1..30).map {|d| d.days.iso8601}, message: "%{value} is not a valid duration" }, if: :duration_changed?
  before_save :parse_duration_in_days

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
