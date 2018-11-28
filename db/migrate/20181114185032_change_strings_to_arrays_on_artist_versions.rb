class ChangeStringsToArraysOnArtistVersions < ActiveRecord::Migration[5.2]
  def up
    ArtistVersion.without_timeout do
      change_column_default :artist_versions, :other_names, from: '', to: false
      change_column :artist_versions, :other_names, "text[]", using: "array_remove(regexp_split_to_array(other_names, '\\s+'), '')", default: "{}"

      change_column :artist_versions, :url_string, "text[]", using: "array_remove(regexp_split_to_array(url_string, '\\s+'), '')", default: "{}"
      rename_column :artist_versions, :url_string, :urls
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
