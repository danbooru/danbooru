class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.column :creator_id, :integer, :null => false
      t.column :post_id, :integer, :null => false
      t.column :x, :integer, :null => false
      t.column :y, :integer, :null => false
      t.column :width, :integer, :null => false
      t.column :height, :integer, :null => false
      t.column :is_active, :boolean, :null => false, :default => true
      t.column :body, :text, :null => false
      t.column :text_index, "tsvector", :null => false
      t.timestamps
    end
    
    add_index :notes, :creator_id
    add_index :notes, :post_id
    execute "CREATE INDEX index_notes_on_text_index ON notes USING GIN (text_index)"
    execute "CREATE TRIGGER trigger_notes_on_update BEFORE INSERT OR UPDATE ON notes FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'body')"
  end

  def self.down
    drop_table :notes
  end
end
