class CreateForumPosts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :forum_posts do |t|
      t.column :topic_id, :integer, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :updater_id, :integer, :null => false
      t.column :body, :text, :null => false
      t.column :text_index, "tsvector", :null => false
      t.column :is_deleted, :boolean, :null => false, :default => false
      t.timestamps
    end

    add_index :forum_posts, :topic_id
    add_index :forum_posts, :creator_id
    execute "CREATE INDEX index_forum_posts_on_text_index ON forum_posts USING GIN (text_index)"
    execute "CREATE TRIGGER trigger_forum_posts_on_update BEFORE INSERT OR UPDATE ON forum_posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'body')"
  end

  def self.down
    drop_table :forum_posts
  end
end
