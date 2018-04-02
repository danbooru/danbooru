class UserPasswordResetNonce < ApplicationRecord
  validates_presence_of :email, :key
  validate :validate_existence_of_email
  before_validation :initialize_key, :on => :create
  after_create :deliver_notice

  def self.prune!
    destroy_all(["created_at < ?", 1.week.ago])
  end

  def deliver_notice
    Maintenance::User::PasswordResetMailer.reset_request(user, self).deliver_now
  end

  def initialize_key
    self.key = SecureRandom.hex(16)
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
