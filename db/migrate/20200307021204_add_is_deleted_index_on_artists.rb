class AddIsDeletedIndexOnArtists < ActiveRecord::Migration[6.0]
  def change
    add_index :artists, :is_deleted
    add_index :artists, :is_banned
  end
end
