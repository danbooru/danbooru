class Favorite
  def self.table_name_for(user)
    "favorites_#{user.id % 10}"
  end
  
  def self.create(user, post)
    ActiveRecord::Base.connection.execute("INSERT INTO #{table_name_for(user)} (user_id, post_id) VALUES (#{user.id}, #{post.id})")
  end
  
  def self.destroy(user, post)
    ActiveRecord::Base.connection.execute("DELETE FROM #{table_name_for(user)} WHERE user_id = #{user.id} AND post_id = #{post.id}")
  end
end
