# frozen_string_literal: true

class UserNameChangeRequest < ApplicationRecord
  belongs_to :user

  attr_accessor :updater

  validate :not_limited, on: :create
  validates :original_name, presence: true
  validates :desired_name, user_name: true, presence: true, on: :create

  after_create :update_name!
  after_create :create_mod_action
  after_create :send_dmail

  def self.visible(user)
    if user.is_moderator?
      all
    elsif user.is_anonymous?
      none
    else
      where(user: User.undeleted)
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :user, :original_name, :desired_name], current_user: current_user)
    q.apply_default_order(params)
  end

  def update_name!
    user.update!(name: desired_name)
  end

  def not_limited
    return if user.name_invalid?
    return if updater && updater != user

    if user.user_name_change_requests.exists?(created_at: (1.week.ago..))
      errors.add(:base, "You can only submit one name change request per week")
    end
  end

  def create_mod_action
    return if updater.nil? || user == updater
    ModAction.log("changed user ##{user.id}'s name from #{original_name} to #{desired_name}", :user_name_change, subject: user, user: updater)
  end

  def send_dmail
    return if updater.nil? || user == updater
    Dmail.create_automated(to: user, disable_email_notifications: true, title: "Your username has been changed", body: <<~EOS)
      Your username has been changed from #{original_name} to #{desired_name}. Your old name was either no longer valid or it violated site rules. You can change it to something else after one week. Please make sure your name follows the [[help:community rules|community rules]].
    EOS
  end
end
