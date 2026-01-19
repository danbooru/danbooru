class AddParentIdToArtistURLs < ActiveRecord::Migration[8.0]
  def change
    add_column :artist_urls, :parent_id, :integer
    add_foreign_key :artist_urls, :artist_urls, column: :parent_id, deferrable: :deferred
  end
end
