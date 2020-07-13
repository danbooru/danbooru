class UserNameChangeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: "User", optional: true

  validate :not_limited, on: :create
  validates :desired_name, user_name: true, confirmation: true, on: :create
  validates_presence_of :original_name, :desired_name

  after_create :update_name!

  def self.visible(user)
    if user.is_moderator?
      all
    elsif user.is_member?
      where(user: User.undeleted)
    else
      none
    end
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :user, :original_name, :desired_name)
    q.apply_default_order(params)
  end

  def update_name!
    user.update!(name: desired_name)
  end

  def not_limited
    if UserNameChangeRequest.unscoped.where(user: user).where("created_at >= ?", 1.week.ago).exists?
      errors[:base] << "You can only submit one name change request per week"
    end
  end
end
