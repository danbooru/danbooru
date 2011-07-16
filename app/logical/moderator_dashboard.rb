class ModeratorDashboard
  attr_reader :min_date, :max_level
  
  def initialize(min_date, max_level)
    @min_date = min_date
    @max_level = max_level
  end
  
  def upload_activity

    
    @upload_activity
  end
  
  def comment_activity(positive = false)
    if positive
      ActiveRecord::Base.select_all_sql("SELECT comment_votes.comment_id, count(*) FROM comment_votes JOIN comments ON comments.id = comment_votes.comment_id JOIN users ON users.id = comments.user_id WHERE comment_votes.created_at > ? AND comments.score > 0 AND users.level <= ? GROUP BY comment_votes.comment_id  HAVING count(*) >= 3 ORDER BY count(*) DESC LIMIT 10", min_date, max_level).map {|x| CommentActivity.new(x)}
    else
      ActiveRecord::Base.select_all_sql("SELECT comment_votes.comment_id, count(*) FROM comment_votes JOIN comments ON comments.id = comment_votes.comment_id JOIN users ON users.id = comments.user_id WHERE comment_votes.created_at > ? AND comments.score < 0 AND users.level <= ? GROUP BY comment_votes.comment_id HAVING count(*) >= 3 ORDER BY count(*) DESC LIMIT 10", min_date, max_level).map {|x| CommentActivity.new(x)}
    end
  end
  
  def post_activity(positive = false)
    ActiveRecord::Base.without_timeout do
      if positive
        @post_activity = ActiveRecord::Base.select_all_sql("SELECT post_votes.post_id, count(*) FROM post_votes JOIN posts ON posts.id = post_votes.post_id JOIN users ON users.id = posts.user_id WHERE post_votes.created_at > ? AND posts.score > 0 AND users.level <= ? GROUP BY post_votes.post_id HAVING count(*) >= 3 ORDER BY count(*) DESC LIMIT 10", min_date, max_level).map {|x| PostActivity.new(x)}
      else
        @post_activity = ActiveRecord::Base.select_all_sql("SELECT post_votes.post_id, count(*) FROM post_votes JOIN posts ON posts.id = post_votes.post_id JOIN users ON users.id = posts.user_id WHERE post_votes.created_at > ? AND posts.score < 0 AND users.level <= ? AND posts.status <> 'deleted' GROUP BY post_votes.post_id HAVING count(*) >= 3 ORDER BY count(*) DESC LIMIT 10", min_date, max_level).map {|x| PostActivity.new(x)}
      end
    end
    
    @post_activity
  end
  
  def tag_activity
    ActiveRecord::Base.without_timeout do
      @tag_activity = ActiveRecord::Base.select_all_sql("SELECT post_tag_histories.user_id, count(*) FROM post_tag_histories JOIN users ON users.id = post_tag_histories.user_id WHERE post_tag_histories.created_at > ? AND users.level <= ? GROUP BY post_tag_histories.user_id ORDER BY count(*) DESC LIMIT 10", min_date, max_level).map {|x| UserActivity.new(x)}
    end
    
    @tag_activity
  end
  
  def note_activity
    ActiveRecord::Base.select_all_sql("SELECT note_versions.user_id, count(*) FROM note_versions JOIN users ON users.id = note_versions.user_id WHERE note_versions.created_at > ? AND users.level <= ? GROUP BY note_versions.user_id ORDER BY count(*) DESC LIMIT 10", min_date, max_level).map {|x| UserActivity.new(x)}
  end
  
  def wiki_page_activity
    ActiveRecord::Base.select_all_sql("SELECT wiki_page_versions.user_id, count(*) FROM wiki_page_versions JOIN users ON users.id = wiki_page_versions.user_id WHERE wiki_page_versions.created_at > ? AND users.level <= ? GROUP BY wiki_page_versions.user_id ORDER BY count(*) DESC LIMIT 10", min_date, max_level).map {|x| UserActivity.new(x)}
  end

  def artist_activity
    ActiveRecord::Base.select_all_sql("SELECT artist_versions.updater_id AS user_id, count(*) FROM artist_versions JOIN users ON users.id = artist_versions.updater_id WHERE artist_versions.created_at > ? AND users.level <= ? GROUP BY artist_versions.updater_id ORDER BY count(*) DESC LIMIT 10", min_date, max_level).map {|x| UserActivity.new(x)}
  end
end
