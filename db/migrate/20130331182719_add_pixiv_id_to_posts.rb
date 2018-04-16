class AddPixivIdToPosts < ActiveRecord::Migration[4.2]
  def up
    execute "set statement_timeout = 0"
    add_column :posts, :pixiv_id, :integer
    execute "drop index index_posts_on_pixiv_id"
    execute "create index index_posts_on_pixiv_id on posts (pixiv_id) where pixiv_id is not null"
  end
  
  def down
    execute "set statement_timeout = 0"
    remove_column :posts, :pixiv_id
  end
end
