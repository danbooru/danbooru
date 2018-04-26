class CreateDmails < ActiveRecord::Migration[4.2]
  def self.up
    create_table :dmails do |t|
      t.column :owner_id, :integer, :null => false
      t.column :from_id, :integer, :null => false
      t.column :to_id, :integer, :null => false
      t.column :title, :text, :null => false
      t.column :body, :text, :null => false
      t.column :message_index, "tsvector", :null => false
      t.column :is_read, :boolean, :null => false, :default => false
      t.column :is_deleted, :boolean, :null => false, :default => false
      t.timestamps
    end

    add_index :dmails, :owner_id

    execute "CREATE INDEX index_dmails_on_message_index ON dmails USING GIN (message_index)"
    execute "CREATE TRIGGER trigger_dmails_on_update BEFORE INSERT OR UPDATE ON dmails FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('message_index', 'pg_catalog.english', 'title', 'body')"
  end

  def self.down
    drop_table :dmails
  end
end
