class AddCreatedAtIndexToVersions < ActiveRecord::Migration
  def change
    ActiveRecord::Base.without_timeout do
      add_index :note_versions, :created_at
      add_index :artist_versions, :created_at
      add_index :wiki_page_versions, :created_at
      add_index :post_appeals, :created_at
    end
  end
end
