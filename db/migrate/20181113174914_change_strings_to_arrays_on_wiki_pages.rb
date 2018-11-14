class ChangeStringsToArraysOnWikiPages < ActiveRecord::Migration[5.2]
  def up
    WikiPage.without_timeout do
      change_column :wiki_pages, :other_names, "text[]", using: "string_to_array(other_names, ' ')::text[]", default: "{}"
      change_column :wiki_page_versions, :other_names, "text[]", using: "string_to_array(other_names, ' ')::text[]", default: "{}"

      remove_column :wiki_pages, :other_names_index
      execute "DROP TRIGGER trigger_wiki_pages_on_update_for_other_names ON wiki_pages"

      add_index :wiki_pages, :other_names, using: :gin
    end
  end

  def down
    WikiPage.without_timeout do
      remove_index :wiki_pages, :other_names

      add_column :wiki_pages, :other_names_index, :tsvector
      add_index :wiki_pages, :other_names_index, using: :gin
      execute "CREATE TRIGGER trigger_wiki_pages_on_update_for_other_names BEFORE INSERT OR UPDATE ON wiki_pages FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('other_names_index', 'public.danbooru', 'other_names')"

      change_column :wiki_pages, :other_names, "text", using: "array_to_string(other_names, ' ')", default: nil
      change_column :wiki_page_versions, :other_names, "text", using: "array_to_string(other_names, ' ')", default: nil
    end
  end
end
