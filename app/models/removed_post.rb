class RemovedPost < ActiveRecord::Base
  module RemovalMethods
    def unremove!
      Post.transaction do
        execute_sql("INSERT INTO posts (#{Post.column_names.join(', ')}) SELECT #{Post.column_names.join(', ')} FROM removed_posts WHERE id = #{id}")
        execute_sql("DELETE FROM removed_posts WHERE id = #{id}")
      end
    end
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

