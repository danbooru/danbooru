class RemovedPost < ActiveRecord::Base
  has_one :unapproval, :dependent => :destroy, :foreign_key => "post_id"
  
  module RemovalMethods
    def unremove!
      Post.transaction do
        execute_sql("INSERT INTO posts (#{Post.column_names.join(', ')}) SELECT #{Post.column_names.join(', ')} FROM removed_posts WHERE id = #{id}")
        execute_sql("DELETE FROM removed_posts WHERE id = #{id}")
      end
    end
  end
  
  def fast_count(tags)
    count = Cache.get("rpfc:#{Cache.sanitize(tags)}")
    if count.nil?
      count = RemovedPost.tag_match("#{tags}").count
      if count > Danbooru.config.posts_per_page * 10
        Cache.put("rpfc:#{Cache.sanitize(tags)}", count, (count * 4).minutes)
      end
    end
    count
  end

  def is_removed?
    true
  end
  
  include Post::FileMethods
  include Post::ImageMethods
  include Post::TagMethods
  include Post::SearchMethods
  include Post::UploaderMethods
  include Post::PoolMethods
  include Post::CountMethods
  include Post::CacheMethods
  include RemovalMethods
end

