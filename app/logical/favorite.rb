class Favorite
  attr_accessor :attributes, :errors
  
  def self.table_name_for(user_id)
    "favorites_#{user_id.to_i % 10}"
  end
  
  def self.create(attributes)
    user_id = attributes[:user_id]
    post_id = attributes[:post_id]
    execute_sql("INSERT INTO #{table_name_for(user_id)} (user_id, post_id) VALUES (?, ?)", user_id, post_id)
  rescue ActiveRecord::RecordNotUnique
    # ignore
  end
  
  def self.destroy(conditions)
    if conditions[:user_id] && conditions[:post_id]
      destroy_for_post_and_user(conditions[:post_id], conditions[:user_id])
    elsif conditions[:user_id]
      destroy_for_user(conditions[:user_id])
    elsif conditions[:post_id]
      destroy_for_post(conditions[:post_id])
    end
  end

  def self.exists?(conditions)
    if conditions[:user_id] && conditions[:post_id]
      select_value_sql("SELECT 1 FROM #{table_name_for(conditions[:user_id])} WHERE user_id = ? AND post_id = ?", conditions[:user_id], conditions[:post_id])
    elsif conditions[:user_id]
      select_value_sql("SELECT 1 FROM #{table_name_for(conditions[:user_id])} WHERE user_id = ?", conditions[:user_id])
    elsif conditions[:post_id]
      select_value_sql("SELECT 1 FROM #{table_name_for(conditions[:user_id])} WHERE post_id = ?", conditions[:post_id])
    else
      false
    end
  end

  private
    def self.destroy_for_post_and_user(post_id, user_id)
      execute_sql("DELETE FROM #{table_name_for(user_id)} WHERE post_id = #{post_id} AND user_id = #{user_id}")
    end
  
    def self.destroy_for_post(post)
      0.upto(9) do |i|
        execute_sql("DELETE FROM favorites_#{i} WHERE post_id = #{post.id}")
      end
    end
  
    def self.destroy_for_user(user)
      execute_sql("DELETE FROM #{table_name_for(user)} WHERE user_id = #{user.id}")
    end
  
    def self.select_value_sql(sql, *params)
      ActiveRecord::Base.select_value_sql(sql, *params)
    end
  
    def self.execute_sql(sql, *params)
      ActiveRecord::Base.execute_sql(sql, *params)
    end
end
