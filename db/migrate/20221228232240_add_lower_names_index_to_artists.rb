class AddLowerNamesIndexToArtists < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    execute <<~EOS
      CREATE OR REPLACE FUNCTION lower(text[]) RETURNS text[] LANGUAGE SQL IMMUTABLE PARALLEL SAFE AS $$
        SELECT array_agg(lower(value)) FROM unnest($1) value;
      $$;
    EOS

    add_index :artists, "lower(ARRAY[name, group_name]::text[] || other_names)", name: "index_artists_on_lower_names", using: :gin, algorithm: :concurrently
  end

  def down
    remove_index :artists, "lower(ARRAY[name, group_name]::text[] || other_names)", name: "index_artists_on_lower_names", using: :gin, algorithm: :concurrently
    execute "DROP FUNCTION IF EXISTS lower(text[])"
  end
end
