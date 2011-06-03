class Favorite
  attr_accessor :attributes, :errors
  
  def self.table_name_for(user_id)
    "favorites_#{user_id.to_i % 10}"
  end
  
  def self.sql_order_clause(post_ids, posts_table_alias = "posts")
    if post_ids.empty?
      return "#{posts_table_alias}.id desc"
    end

    conditions = []
    
    post_ids.each_with_index do |post_id, n|
      conditions << "when #{post_id} then #{n}"
    end
    
    "case #{posts_table_alias}.id " + conditions.join(" ") + " end"
  end
  
  def self.create(attributes)
    user_id = attributes[:user_id]
    post_id = attributes[:post_id]
    execute_sql("INSERT INTO #{table_name_for(user_id)} (user_id, post_id) VALUES (?, ?)", user_id, post_id)
  rescue ActiveRecord::RecordNotUnique
    # ignore
  end
  
  def self.count(user_id)
    select_value_sql("SELECT COUNT(*) FROM #{table_name_for(user_id)}").to_i
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
  
  def self.find_post_ids(user_id, options)
    limit = options[:limit] || 1 || Danbooru.config.posts_per_page
    if options[:before_id]
      select_values_sql("SELECT post_id FROM #{table_name_for(user_id)} WHERE id < ? ORDER BY id DESC LIMIT ?", options[:before_id], limit)
    elsif options[:after_id]
      select_values_sql("SELECT post_id FROM #{table_name_for(user_id)} WHERE id > ? ORDER BY id ASC LIMIT ?", options[:after_id], limit).reverse
    elsif options[:offset]
      select_values_sql("SELECT post_id FROM #{table_name_for(user_id)} ORDER BY id DESC LIMIT ? OFFSET ?",  limit, options[:offset])
    else
      select_values_sql("SELECT post_id FROM #{table_name_for(user_id)} ORDER BY id DESC LIMIT ?", limit)
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

  def self.select_values_sql(sql, *params)
    ActiveRecord::Base.select_values_sql(sql, *params)
  end

  def self.execute_sql(sql, *params)
    ActiveRecord::Base.execute_sql(sql, *params)
  end
end

