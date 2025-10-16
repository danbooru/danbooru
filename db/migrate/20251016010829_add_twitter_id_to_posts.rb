class AddTwitterIdToPosts < ActiveRecord::Migration[8.0]
  def up
    execute "set statement_timeout = 0"
    add_column :posts, :twitter_id, :bigint
    execute "drop index if exists index_posts_on_twitter_id"
    execute "create index index_posts_on_twitter_id on posts (twitter_id) where twitter_id is not null"
  end

  def down
    execute "set statement_timeout = 0"
    remove_column :posts, :twitter_id
  end
end
