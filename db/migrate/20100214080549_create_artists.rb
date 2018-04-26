class CreateArtists < ActiveRecord::Migration[4.2]
  def self.up
    create_table :artists do |t|
      t.column :name, :string, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :is_active, :boolean, :null => false, :default => true
      t.column :is_banned, :boolean, :null => false, :default => false
      t.column :other_names, :text
      t.column :other_names_index, "tsvector"
      t.column :group_name, :string
      t.timestamps
    end

    add_index :artists, :name, :unique => true
    add_index :artists, :group_name
    execute "CREATE INDEX index_artists_on_other_names_index ON artists USING GIN (other_names_index)"
    execute "CREATE TRIGGER trigger_artists_on_update BEFORE INSERT OR UPDATE ON artists FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('other_names_index', 'public.danbooru', 'other_names')"
  end

  def self.down
    drop_table :artists
  end
end
