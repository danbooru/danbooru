class UserFeedback < ActiveRecord::Base
  set_table_name "user_feedback"
  belongs_to :user
  attr_accessible :body, :user_id, :is_positive
end
