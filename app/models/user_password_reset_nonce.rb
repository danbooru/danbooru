class UserPasswordResetNonce < ApplicationRecord
  has_secure_token :key
  validates_presence_of :email
  validate :validate_existence_of_email
  after_create :deliver_notice

  def self.prune!
    where("created_at < ?", 1.week.ago).destroy_all
  end

  def deliver_notice
    Maintenance::User::PasswordResetMailer.reset_request(user, self).deliver_now
  end

  def validate_existence_of_email
    if !User.with_email(email).exists?
      errors[:email] << "is invalid"
      return false
    end
  end

  def reset_user!
    user.reset_password_and_deliver_notice
  end

  def user
    @user ||= User.with_email(email).first
  end
end
