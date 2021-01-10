class AddArrayToTsvectorIndexOnWikiPagesAndArtists < ActiveRecord::Migration[6.1]
  def change
    add_index :wiki_pages, "array_to_tsvector(other_names)", using: :gin
    add_index :artists, "array_to_tsvector(other_names)", using: :gin
  end
end
