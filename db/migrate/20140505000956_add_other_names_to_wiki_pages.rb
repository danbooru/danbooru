class AddOtherNamesToWikiPages < ActiveRecord::Migration[4.2]
  def change
    add_column :wiki_pages, :other_names, :text
    add_column :wiki_pages, :other_names_index, :tsvector
    add_column :wiki_page_versions, :other_names, :text

    execute "CREATE INDEX index_wiki_pages_on_other_names_index ON wiki_pages USING GIN (other_names_index)"
    execute "CREATE TRIGGER trigger_wiki_pages_on_update_for_other_names BEFORE INSERT OR UPDATE ON wiki_pages FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('other_names_index', 'public.danbooru', 'other_names')"
  end
end
