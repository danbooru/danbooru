class ChangeSourceToNonNullOnPosts < ActiveRecord::Migration
  def up
    Post.without_timeout do
      change_column_null(:posts, :source, false, "")
      change_column_default(:posts, :source, "")
    end
  end

  def down
    Post.without_timeout do
      change_column_null(:posts, :source, true)
      change_column_default(:posts, :source, nil)
    end
  end
end
