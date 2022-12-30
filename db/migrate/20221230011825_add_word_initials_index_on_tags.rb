class AddWordInitialsIndexOnTags < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    execute <<~EOS
      CREATE OR REPLACE FUNCTION array_initials(text[]) RETURNS text LANGUAGE SQL IMMUTABLE PARALLEL SAFE AS $$
        SELECT string_agg(left(string, 1), '') FROM unnest($1) string;
      $$;
    EOS

    add_index :tags, "array_initials(words) gin_trgm_ops", name: "index_tags_on_word_initials", using: :gin, algorithm: :concurrently
  end

  def down
    remove_index :tags, "array_initials(words) gin_trgm_ops", name: "index_tags_on_word_initials", using: :gin, algorithm: :concurrently
    execute "DROP FUNCTION IF EXISTS array_initials(text[])"
  end
end
