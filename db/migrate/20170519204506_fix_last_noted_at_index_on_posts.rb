class FixLastNotedAtIndexOnPosts < ActiveRecord::Migration[4.2]
  def up
    Post.without_timeout do
      remove_index :posts, column: :last_comment_bumped_at
      add_index :posts, :last_comment_bumped_at, order: "DESC NULLS LAST"

      remove_index :posts, column: :last_noted_at
      add_index :posts, :last_noted_at, order: "DESC NULLS LAST"

      execute "analyze posts"
    end
  end
end
