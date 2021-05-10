class ChangeFieldsToNonNullOnArtistCommentaryVersions < ActiveRecord::Migration[6.0]
  def up
    change_column_null(:artist_commentary_versions, :original_title, false, "")
    change_column_null(:artist_commentary_versions, :translated_title, false, "")
    change_column_null(:artist_commentary_versions, :original_description, false, "")
    change_column_null(:artist_commentary_versions, :translated_description, false, "")

    change_column_default(:artist_commentary_versions, :original_title, "")
    change_column_default(:artist_commentary_versions, :translated_title, "")
    change_column_default(:artist_commentary_versions, :original_description, "")
    change_column_default(:artist_commentary_versions, :translated_description, "")
  end

  def down
    change_column_null(:artist_commentary_versions, :original_title, true)
    change_column_null(:artist_commentary_versions, :translated_title, true)
    change_column_null(:artist_commentary_versions, :original_description, true)
    change_column_null(:artist_commentary_versions, :translated_description, true)

    change_column_default(:artist_commentary_versions, :original_title, nil)
    change_column_default(:artist_commentary_versions, :translated_title, nil)
    change_column_default(:artist_commentary_versions, :original_description, nil)
    change_column_default(:artist_commentary_versions, :translated_description, nil)
  end
end
