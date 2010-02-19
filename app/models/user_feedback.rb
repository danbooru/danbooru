class UserFeedback < ActiveRecord::Base
  set_table_name "user_feedback"
  belongs_to :user
  belongs_to :creator, :class_name => "User"
  attr_accessible :body, :user_id, :is_positive
  validates_presence_of :user_id, :creator_id, :body
  validate :creator_is_privileged
  
  def creator_is_privileged
    if !creator.is_privileged?
      errors[:creator] << "must be privileged"
    end
  end
end
