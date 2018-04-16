class AddLastCommentBumpedAtToPosts < ActiveRecord::Migration[4.2]
  def self.up
    execute "SET statement_timeout = 0"

    rename_column :posts, :last_commented_at, :last_comment_bumped_at
    # rename_index :posts, :index_posts_on_last_commented_at, :index_posts_on_last_comment_bumped_at

    add_column :posts, :last_commented_at, :datetime
    add_column :comments, :do_not_bump_post, :boolean, :null => false, :default => false
  end

  def self.down
    execute "SET statement_timeout = 0"

    remove_column :posts, :last_commented_at

    rename_column :posts, :last_comment_bumped_at, :last_commented_at
    # rename_index :posts, "index_posts_on_last_comment_bumped_at", "index_posts_on_last_commented_at"

    remove_column :comments, :do_not_bump_posts
  end
end
