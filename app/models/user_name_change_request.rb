class UserNameChangeRequest < ApplicationRecord
  after_initialize :initialize_attributes, if: :new_record?
  validates_presence_of :user_id, :original_name, :desired_name
  validates_inclusion_of :status, :in => %w(pending approved rejected)
  belongs_to :user
  belongs_to :approver, :class_name => "User"
  validate :not_limited, :on => :create
  validates :desired_name, user_name: true

  def initialize_attributes
    self.user_id ||= CurrentUser.user.id
    self.original_name ||= CurrentUser.user.name
  end
  
  def self.pending
    where(:status => "pending")
  end

  def self.approved
    where(:status => "approved")
  end

  def self.visible(viewer = CurrentUser.user)
    if viewer.is_admin?
      all
    elsif viewer.is_member?
      joins(:user).merge(User.undeleted).where("user_name_change_requests.status = 'approved' OR user_name_change_requests.user_id = ?", viewer.id)
    else
      none
    end
  end
  
  def rejected?
    status == "rejected"
  end
  
  def approved?
    status == "approved"
  end

  def pending?
    status == "pending"
  end
  
  def feedback
    UserFeedback.for_user(user_id).order("id desc")
  end
  
  def approve!
    update_attributes(:status => "approved", :approver_id => CurrentUser.user.id)
    user.update_attribute(:name, desired_name)
    body = "Your name change request has been approved. Be sure to log in with your new user name."
    Dmail.create_automated(:title => "Name change request approved", :body => body, :to_id => user_id)
    UserFeedback.create(:user_id => user_id, :category => "neutral", :body => "Name changed from #{original_name} to #{desired_name}")
    ModAction.log("Name changed from #{original_name} to #{desired_name}",:user_name_change)
  end
  
  def reject!(reason)
    update_attributes(:status => "rejected", :rejection_reason => reason)
    body = "Your name change request has been rejected for the following reason: #{rejection_reason}"
    Dmail.create_automated(:title => "Name change request rejected", :body => body, :to_id => user_id)
  end
  
  def not_limited
    if UserNameChangeRequest.where("user_id = ? and created_at >= ?", CurrentUser.user.id, 1.week.ago).exists?
      errors.add(:base, "You can only submit one name change request per week")
      return false
    else
      return true
    end
  end

  def hidden_attributes
    if CurrentUser.is_admin? || user == CurrentUser.user
      []
    else
      super + [:change_reason, :rejection_reason]
    end
  end
end
