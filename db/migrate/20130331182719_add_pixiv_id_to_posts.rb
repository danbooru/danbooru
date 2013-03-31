class AddPixivIdToPosts < ActiveRecord::Migration
  def up
    execute "set statement_timeout = 0"
    add_column :posts, :pixiv_id, :integer
    execute "create index index_posts_on_pixiv_id on posts (pixiv_id) where pixiv_id is not null"
  end
  
  def down
    execute "set statement_timeout = 0"
    remove_column :posts, :pixiv_id
  end
end
