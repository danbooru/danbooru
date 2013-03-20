class AddUpdaterIdToWikiPages < ActiveRecord::Migration
  def change
    add_column :wiki_pages, :updater_id, :integer
  end
end
