class RenameIsActiveOnArtists < ActiveRecord::Migration[6.0]
  def up
    execute "SET statement_timeout = 0"

    rename_column :artists, :is_active, :is_deleted
    change_column_default :artists, :is_deleted, from: true, to: false
    execute "UPDATE artists SET is_deleted = NOT is_deleted"

    rename_column :artist_versions, :is_active, :is_deleted
    change_column_default :artist_versions, :is_deleted, from: true, to: false
    execute "UPDATE artist_versions SET is_deleted = NOT is_deleted"
  end

  def down
    execute "SET statement_timeout = 0"

    execute "UPDATE artists SET is_deleted = NOT is_deleted"
    change_column_default :artists, :is_deleted, from: false, to: true
    rename_column :artists, :is_deleted, :is_active

    execute "UPDATE artist_versions SET is_deleted = NOT is_deleted"
    change_column_default :artist_versions, :is_deleted, from: false, to: true
    rename_column :artist_versions, :is_deleted, :is_active
  end
end
