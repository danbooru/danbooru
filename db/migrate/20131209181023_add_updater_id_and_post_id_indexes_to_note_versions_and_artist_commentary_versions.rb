class AddUpdaterIdAndPostIdIndexesToNoteVersionsAndArtistCommentaryVersions < ActiveRecord::Migration
  def self.up
    execute "set statement_timeout = 0"
    remove_index :note_versions, :updater_id
    remove_index :artist_commentary_versions, :updater_id
    add_index :note_versions, [:updater_id, :post_id]
    add_index :artist_commentary_versions, [:updater_id, :post_id]
  end

  def self.down
    execute "set statement_timeout = 0"
    remove_index :note_versions, [:updater_id, :post_id]
    remove_index :artist_commentary_versions, [:updater_id, :post_id]
    add_index :note_versions, :updater_id
    add_index :artist_commentary_versions, :updater_id
  end
end
