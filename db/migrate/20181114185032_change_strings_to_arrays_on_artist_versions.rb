class ChangeStringsToArraysOnArtistVersions < ActiveRecord::Migration[5.2]
  def up
    ArtistVersion.without_timeout do
      add_column :artist_versions, :other_names_array, "text[]", default: "{}"
      execute "update artist_versions set other_names_array = array_remove(regexp_split_to_array(other_names, '\\s+'), '')"
      remove_column :artist_versions, :other_names
      rename_column :artist_versions, :other_names_array, :other_names

      add_column :artist_versions, :urls, "text[]", default: "{}"
      execute "update artist_versions set urls = array_remove(regexp_split_to_array(url_string, '\\s+'), '')"
      remove_column :artist_versions, :url_string
    end
  end

  def down
    ArtistVersion.without_timeout do
      rename_column :artist_versions, :urls, :url_string
      change_column :artist_versions, :url_string,  "text", using: "array_to_string(url_string,  '\\n')", default: nil

      change_column :artist_versions, :other_names, "text", using: "array_to_string(other_names, ' ')", default: nil
    end
  end
end
