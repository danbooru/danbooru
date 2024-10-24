# frozen_string_literal: true

class NewsUpdate < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to_updater

  deletable
  scope :unexpired, -> { where("created_at + duration >= ?", Time.zone.now) }
  scope :expired, -> { where("created_at + duration < ?", Time.zone.now) }

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
