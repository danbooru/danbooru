class UserFeedback < ActiveRecord::Base
  set_table_name "user_feedback"
  belongs_to :user
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  attr_accessible :body, :user_id, :is_positive, :user_name
  validates_presence_of :user, :creator, :body
  validate :creator_is_privileged
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
  
  def user_name=(name)
    self.user_id = User.name_to_id(name)
  end
  
  def creator_is_privileged
    if !creator.is_privileged?
      errors[:creator] << "must be privileged"
    end
  end
end
