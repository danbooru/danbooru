class CreateWikiPages < ActiveRecord::Migration[4.2]
  def self.up
    create_table :wiki_pages do |t|
      t.column :creator_id, :integer, :null => false
      t.column :title, :string, :null => false
      t.column :body, :text, :null => false
      t.column :body_index, "tsvector", :null => false
      t.column :is_locked, :boolean, :null => false, :default => false
      t.timestamps
    end

    add_index :wiki_pages, :title, :unique => true
    execute "CREATE INDEX index_wiki_pages_on_body_index_index ON wiki_pages USING GIN (body_index)"
    execute "CREATE TRIGGER trigger_wiki_pages_on_update BEFORE INSERT OR UPDATE ON wiki_pages FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'public.danbooru', 'body', 'title')"
    execute "create index index_wiki_pages_on_title_pattern on wiki_pages (title text_pattern_ops)"
  end

  def self.down
    drop_table :wiki_pages
  end
end
