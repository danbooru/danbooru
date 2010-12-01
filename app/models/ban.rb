class Ban < ActiveRecord::Base
  after_create :update_feedback
  belongs_to :user
  belongs_to :banner, :class_name => "User"
  attr_accessible :reason, :duration, :user_id
  validate :user_is_inferior
  
  def self.is_banned?(user)
    exists?(["user_id = ? AND expires_at > ?", user.id, Time.now])
  end
  
  def user_is_inferior
    if user
      if user.is_admin?
        errors[:base] << "You can never ban an admin."      
        false
      elsif user.is_moderator? && banner.is_admin?
        true
      elsif user.is_moderator?
        errors[:base] << "Only admins can ban moderators."
        false
      elsif banner.is_admin? || banner.is_moderator?
        true
      else
        errors[:base] << "No one else can ban."
        false
      end
    end
  end
  
  def update_feedback
    if user
      feedback = user.feedback.build
      feedback.is_positive = false
      feedback.body = "Banned: #{reason}"
      feedback.creator_id = banner_id
      feedback.save
    end
  end
  
  def user_name
    user ? user.name : nil
  end
  
  def user_name=(username)
    self.user_id = User.name_to_id(username)
  end
  
  def duration=(dur)
    self.expires_at = dur.to_i.days.from_now
    @duration = dur
  end
  
  def duration
    @duration
  end
end
