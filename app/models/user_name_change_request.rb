class UserNameChangeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: "User", optional: true

  validate :not_limited, on: :create
  validates :desired_name, user_name: true
  validates_presence_of :original_name, :desired_name

  after_create :approve!

  def self.visible(viewer = CurrentUser.user)
    if viewer.is_admin?
      all
    elsif viewer.is_member?
      joins(:user).merge(User.undeleted).where("user_name_change_requests.user_id = ?", viewer.id)
    else
      none
    end
  end

  def approve!
    user.update_attribute(:name, desired_name)
    body = "Your name change request has been approved. Be sure to log in with your new user name."
    Dmail.create_automated(:title => "Name change request approved", :body => body, :to_id => user_id)
    UserFeedback.create(:user_id => user_id, :category => "neutral", :body => "Name changed from #{original_name} to #{desired_name}")
    ModAction.log("Name changed from #{original_name} to #{desired_name}",:user_name_change)
  end

  def not_limited
    if UserNameChangeRequest.unscoped.where(user: user).where("created_at >= ?", 1.week.ago).exists?
      errors[:base] << "You can only submit one name change request per week"
    end
  end
end
