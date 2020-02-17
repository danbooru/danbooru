class DropCreatorFromArtistsNotesPools < ActiveRecord::Migration[6.0]
  def change
    remove_index :pools, column: [:creator_id]
    remove_index :notes, column: [:creator_id, :post_id]

    remove_column :artists, :creator_id, :integer, null: false
    remove_column :notes, :creator_id, :integer, null: false
    remove_column :pools, :creator_id, :integer, null: false
  end
end
