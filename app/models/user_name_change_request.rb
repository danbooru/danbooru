# frozen_string_literal: true

class UserNameChangeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: "User", optional: true

  validate :not_limited, on: :create
  validates :desired_name, user_name: true, confirmation: true, on: :create
  validates :original_name, presence: true
  validates :desired_name, presence: true

  after_create :update_name!

  def self.visible(user)
    if user.is_moderator?
      all
    elsif user.is_anonymous?
      none
    else
      where(user: User.undeleted)
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :user, :original_name, :desired_name)
    q.apply_default_order(params)
  end

  def update_name!
    user.update!(name: desired_name)
  end

  def not_limited
    return if user.name_invalid?

    if UserNameChangeRequest.unscoped.where(user: user).exists?(["created_at >= ?", 1.week.ago])
      errors.add(:base, "You can only submit one name change request per week")
    end
  end
end
