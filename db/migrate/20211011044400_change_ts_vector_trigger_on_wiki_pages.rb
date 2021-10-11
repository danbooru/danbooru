class ChangeTsVectorTriggerOnWikiPages < ActiveRecord::Migration[6.1]
  def up
    execute("DROP TRIGGER trigger_wiki_pages_on_update ON wiki_pages")
    execute("CREATE TRIGGER trigger_wiki_pages_on_update BEFORE INSERT OR UPDATE ON public.wiki_pages FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('body_index', 'pg_catalog.english', 'body', 'title')")
  end

  def down
    execute("DROP TRIGGER trigger_wiki_pages_on_update ON wiki_pages")
    execute("CREATE TRIGGER trigger_wiki_pages_on_update BEFORE INSERT OR UPDATE ON public.wiki_pages FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('body_index', 'public.danbooru', 'body', 'title')")
  end
end
