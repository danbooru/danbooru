class AddIndexesToArtistCommentaries < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :artist_commentaries, "to_tsvector('english', original_title)", using: :gin, name: "index_artist_commentaries_on_to_tsvector_original_title", algorithm: :concurrently
    add_index :artist_commentaries, "to_tsvector('english', original_description)", using: :gin, name: "index_artist_commentaries_on_to_tsvector_original_description", algorithm: :concurrently
    add_index :artist_commentaries, "to_tsvector('english', translated_title)", using: :gin, name: "index_artist_commentaries_on_to_tsvector_translated_title", algorithm: :concurrently
    add_index :artist_commentaries, "to_tsvector('english', translated_description)", using: :gin, name: "index_artist_commentaries_on_to_tsvector_translated_description", algorithm: :concurrently
    add_index :artist_commentaries, :created_at

    add_index :artist_commentary_versions, "to_tsvector('english', original_title)", using: :gin, name: "index_artist_commentary_versions_on_original_title", algorithm: :concurrently
    add_index :artist_commentary_versions, "to_tsvector('english', original_description)", using: :gin, name: "index_artist_commentary_versions_on_original_description", algorithm: :concurrently
    add_index :artist_commentary_versions, "to_tsvector('english', translated_title)", using: :gin, name: "index_artist_commentary_versions_on_translated_title", algorithm: :concurrently
    add_index :artist_commentary_versions, "to_tsvector('english', translated_description)", using: :gin, name: "index_artist_commentary_versions_on_translated_description", algorithm: :concurrently

    add_index :dmails, "to_tsvector('english', title)", using: :gin, algorithm: :concurrently
    add_index :dmails, "to_tsvector('english', body)", using: :gin, algorithm: :concurrently

    add_index :wiki_pages, "to_tsvector('english', title)", using: :gin, algorithm: :concurrently
    add_index :wiki_pages, "to_tsvector('english', body)", using: :gin, algorithm: :concurrently
  end
end
