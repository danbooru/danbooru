class AddUpdatedAtIndexOnWikiPages < ActiveRecord::Migration[4.2]
  def change
    WikiPage.without_timeout do
      add_index :wiki_pages, :updated_at
    end
  end
end
