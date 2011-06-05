class Favorite < ActiveRecord::Base
  TABLE_COUNT = 100
  validates_uniqueness_of :post_id, :scope => :user_id
  
  def self.model_for(user_id)
    mod = user_id % TABLE_COUNT
    Object.const_get("Favorite#{mod}")
  end
  
  def self.delete_post(post_id)
    0.upto(TABLE_COUNT - 1) do |i|
      model_for(i).destroy_all(:post_id => post_id)
    end
  end
end

0.upto(Favorite::TABLE_COUNT - 1) do |i|
  Object.const_set("Favorite#{i}", Class.new(Favorite))
  Object.const_get("Favorite#{i}").set_table_name("favorites_#{i}")
end
