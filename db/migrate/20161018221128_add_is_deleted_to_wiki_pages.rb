class AddIsDeletedToWikiPages < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :wiki_pages, :is_deleted, :boolean, :null => false, :default => false
    add_column :wiki_page_versions, :is_deleted, :boolean, :null => false, :default => false
  end
end
