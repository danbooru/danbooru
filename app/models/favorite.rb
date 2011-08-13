class Favorite < ActiveRecord::Base
  belongs_to :post
  scope :for_user, lambda {|user_id| where("user_id = #{user_id}")}
end
