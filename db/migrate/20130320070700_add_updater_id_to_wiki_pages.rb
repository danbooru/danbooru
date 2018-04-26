class AddUpdaterIdToWikiPages < ActiveRecord::Migration[4.2]
  def change
    add_column :wiki_pages, :updater_id, :integer
  end
end
