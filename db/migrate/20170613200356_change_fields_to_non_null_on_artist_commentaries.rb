class ChangeFieldsToNonNullOnArtistCommentaries < ActiveRecord::Migration
  def up
    ArtistCommentary.without_timeout do
      change_column_null(:artist_commentaries, :original_title, false, "")
      change_column_null(:artist_commentaries, :translated_title, false, "")
      change_column_null(:artist_commentaries, :original_description, false, "")
      change_column_null(:artist_commentaries, :translated_description, false, "")

      change_column_default(:artist_commentaries, :original_title, "")
      change_column_default(:artist_commentaries, :translated_title, "")
      change_column_default(:artist_commentaries, :original_description, "")
      change_column_default(:artist_commentaries, :translated_description, "")
    end
  end

  def down
    ArtistCommentary.without_timeout do
      change_column_null(:artist_commentaries, :original_title, true)
      change_column_null(:artist_commentaries, :translated_title, true)
      change_column_null(:artist_commentaries, :original_description, true)
      change_column_null(:artist_commentaries, :translated_description, true)

      change_column_default(:artist_commentaries, :original_title, nil)
      change_column_default(:artist_commentaries, :translated_title, nil)
      change_column_default(:artist_commentaries, :original_description, nil)
      change_column_default(:artist_commentaries, :translated_description, nil)
    end
  end
end
