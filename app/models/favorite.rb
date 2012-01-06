class Favorite < ActiveRecord::Base
  belongs_to :post
  scope :for_user, lambda {|user_id| where("user_id % 100 = #{user_id.to_i % 100} and user_id = #{user_id.to_i}")}
  
  # this is necessary because there's no trigger for deleting favorites
  def self.destroy_all(hash)
    connection.execute("delete from favorites_#{hash[:user_id] % 100} where user_id = #{hash[:user_id]} and post_id = #{hash[:post_id]}")
  end
end
