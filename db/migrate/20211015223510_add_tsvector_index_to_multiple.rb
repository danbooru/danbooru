class AddTsvectorIndexToMultiple < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_index :comments, "to_tsvector('pg_catalog.english', body)", using: :gin, algorithm: :concurrently, name: "index_comments_on_body_tsvector"
    add_index :dmails, "(to_tsvector('pg_catalog.english', title) || to_tsvector('pg_catalog.english', body))", using: :gin, algorithm: :concurrently, name: "index_dmails_on_title_and_body_tsvector"
    add_index :forum_posts, "to_tsvector('pg_catalog.english', body)", using: :gin, algorithm: :concurrently, name: "index_forum_posts_on_body_tsvector"
    add_index :forum_topics, "to_tsvector('pg_catalog.english', title)", using: :gin, algorithm: :concurrently, name: "index_forum_topics_on_title_tsvector"
    add_index :notes, "to_tsvector('pg_catalog.english', body)", using: :gin, algorithm: :concurrently, name: "index_notes_on_body_tsvector"
    add_index :wiki_pages, "(to_tsvector('pg_catalog.english', title) || to_tsvector('pg_catalog.english', body))", using: :gin, algorithm: :concurrently, name: "index_wiki_pages_on_title_and_body_tsvector"

    execute("VACUUM (VERBOSE, ANALYZE) comments")
    execute("VACUUM (VERBOSE, ANALYZE) dmails")
    execute("VACUUM (VERBOSE, ANALYZE) forum_posts")
    execute("VACUUM (VERBOSE, ANALYZE) forum_topics")
    execute("VACUUM (VERBOSE, ANALYZE) notes")
    execute("VACUUM (VERBOSE, ANALYZE) wiki_pages")
  end

  def down
    remove_index :comments, algorithm: :concurrently, name: "index_comments_on_body_tsvector"
    remove_index :dmails, algorithm: :concurrently, name: "index_dmails_on_title_and_body_tsvector"
    remove_index :forum_posts, algorithm: :concurrently, name: "index_forum_posts_on_body_tsvector"
    remove_index :forum_topics, algorithm: :concurrently, name: "index_forum_topics_on_title_tsvector"
    remove_index :notes, algorithm: :concurrently, name: "index_notes_on_body_tsvector"
    remove_index :wiki_pages, algorithm: :concurrently, name: "index_wiki_pages_on_title_and_body_tsvector"
  end
end
