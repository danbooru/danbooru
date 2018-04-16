class CreateComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :comments do |t|
      t.column :post_id, :integer, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :body, :text, :null => false
      t.column :ip_addr, "inet", :null => false
      t.column :body_index, "tsvector", :null => false
      t.column :score, :integer, :null => false, :default => 0
      t.timestamps
    end

    add_index :comments, :post_id
    execute "CREATE INDEX index_comments_on_body_index ON comments USING GIN (body_index)"
    execute "CREATE TRIGGER trigger_comments_on_update BEFORE INSERT OR UPDATE ON comments FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body')"
  end

  def self.down
    drop_table :comments
  end
end
