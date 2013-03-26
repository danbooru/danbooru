class UserNameChangeRequest < ActiveRecord::Base
  validates_presence_of :user_id, :original_name, :desired_name
  validates_inclusion_of :status, :in => %w(pending approved rejected)
  belongs_to :user
  belongs_to :approver, :class_name => "User"
  validate :uniqueness_of_desired_name
  validates_length_of :desired_name, :within => 2..100, :on => :create
  validates_format_of :desired_name, :with => /\A[^\s:]+\Z/, :on => :create, :message => "cannot have whitespace or colons"
  after_create :notify_admins
  
  def self.pending
    where(:status => "pending")
  end
  
  def feedback
    UserFeedback.for_user(user_id).order("id desc").all
  end
  
  def notify_admins
    title = "#{original_name} is requesting a name change to #{desired_name}"
    body = title + "\n\n\"See request\":/user_name_change_requests/#{id}"
    User.admins.find_each do |user|
      Dmail.create_split(:title => title, :body => body, :to_id => user.id)
    end
  end
  
  def approve!
    update_attribute(:status, "approved")
    user.update_attribute(:name, desired_name)
    body = "Your name change request has been approved. Be sure to log in with your new user name."
    Dmail.create_split(:title => "Name change request approved", :body => body, :to_id => user_id)
  end
  
  def reject!(reason)
    update_attributes(:status => "rejected", :rejection_reason => reason)
    body = "Your name change request has been rejected for the following reason: #{rejection_reason}"
    Dmail.create_split(:title => "Name change request rejected", :body => body, :to_id => user_id)
  end
  
  def uniqueness_of_desired_name
    if User.find_by_name(desired_name)
      errors.add(:desired_name, "already exists")
      return false
    else
      return true
    end
  end
end
