class AddIsActiveToArtistUrls < ActiveRecord::Migration[5.2]
  def change
    ApplicationRecord.without_timeout do
      add_column :artist_urls, :is_active, :boolean, null: false, default: true
    end
  end
end
