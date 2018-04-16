class DropIndexPostsOnCreatedAtDate < ActiveRecord::Migration[4.2]
  def up
    execute "set statement_timeout = 0"
    execute "drop index index_posts_on_created_at_date"
  end

  def down
    execute "set statement_timeout = 0"
    execute "create index index_posts_on_created_at_date on posts(date(created_at))"
  end
end
