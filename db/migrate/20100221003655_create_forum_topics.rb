class CreateForumTopics < ActiveRecord::Migration[4.2]
  def self.up
    create_table :forum_topics do |t|
      t.column :creator_id, :integer, :null => false
      t.column :updater_id, :integer, :null => false
      t.column :title, :string, :null => false
      t.column :response_count, :integer, :null => false, :default => 0
      t.column :is_sticky, :boolean, :null => false, :default => false
      t.column :is_locked, :boolean, :null => false, :default => false
      t.column :is_deleted, :boolean, :null => false, :default => false
      t.column :text_index, "tsvector", :null => false
      t.timestamps
    end

    add_index :forum_topics, :creator_id

    execute "CREATE INDEX index_forum_topics_on_text_index ON forum_topics USING GIN (text_index)"
    execute "CREATE TRIGGER trigger_forum_topics_on_update BEFORE INSERT OR UPDATE ON forum_topics FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'title')"
  end

  def self.down
    drop_table :forum_topics
  end
end
