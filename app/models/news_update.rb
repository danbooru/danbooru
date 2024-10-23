# frozen_string_literal: true

class NewsUpdate < ApplicationRecord
  EXPIRE_TIME = 2.weeks

  belongs_to :creator, class_name: "User"
  belongs_to_updater

  deletable
  scope :recent, -> {active.where(created_at: EXPIRE_TIME.ago..).order(created_at: :desc).limit(5)}

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

    flags << "Expired" if created_at <= EXPIRE_TIME.ago
    flags << "Deleted" if is_deleted

    flags << "Active" if flags.empty?

    flags.join(", ")
  end

  def expired_at
    created_at + EXPIRE_TIME
  end
end
