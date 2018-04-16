class CreateWikiPageVersions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :wiki_page_versions do |t|
      t.column :wiki_page_id, :integer, :null => false
      t.column :updater_id, :integer, :null => false
      t.column :updater_ip_addr, "inet", :null => false
      t.column :title, :string, :null => false
      t.column :body, :text, :null => false
      t.column :is_locked, :boolean, :null => false
      t.timestamps
    end

    add_index :wiki_page_versions, :wiki_page_id
  end

  def self.down
    drop_table :wiki_page_versions
  end
end
