class ChangeOtherNamesToArrayOnArtists < ActiveRecord::Migration[5.2]
  def up
    Artist.without_timeout do
      change_column_default :artists, :other_names, from: '', to: false
      remove_index :artists, name: "index_artists_on_other_names_trgm"
      change_column :artists, :other_names, "text[]", using: "array_remove(regexp_split_to_array(other_names, '\\s+'), '')", default: "{}"
      add_index :artists, :other_names, using: :gin

      remove_column :artists, :other_names_index
      execute "DROP TRIGGER trigger_artists_on_update ON artists"
    end
  end

  def down
    Artist.without_timeout do
      remove_index :artists, :other_names
      change_column :artists, :other_names, "text", using: "array_to_string(other_names, ' ')", default: nil
      add_index :artists, :other_names, name: "index_artists_on_other_names_trgm", using: :gin, opclass: :gin_trgm_ops

      add_column :artists, :other_names_index, :tsvector
      execute "CREATE TRIGGER trigger_artists_on_update BEFORE INSERT OR UPDATE ON artists FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('other_names_index', 'public.danbooru', 'other_names')"
    end
  end
end
