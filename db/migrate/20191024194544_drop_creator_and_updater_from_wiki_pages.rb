class DropCreatorAndUpdaterFromWikiPages < ActiveRecord::Migration[6.0]
  def change
    remove_column :wiki_pages, :creator_id, :integer
    remove_column :wiki_pages, :updater_id, :integer
  end
end
