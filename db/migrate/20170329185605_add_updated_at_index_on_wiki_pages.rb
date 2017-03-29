class AddUpdatedAtIndexOnWikiPages < ActiveRecord::Migration
  def change
    WikiPage.without_timeout do
      add_index :wiki_pages, :updated_at
    end
  end
end
