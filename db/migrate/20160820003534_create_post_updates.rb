class CreatePostUpdates < ActiveRecord::Migration
  def up
    execute "create unlogged table post_updates ( post_id integer, constraint unique_post_id unique(post_id) )"
  end

  def down
    execute "drop table post_updates"
  end
end
