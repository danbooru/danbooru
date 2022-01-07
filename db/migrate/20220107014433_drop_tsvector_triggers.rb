class DropTsvectorTriggers < ActiveRecord::Migration[6.1]
  def up
    execute "DROP TRIGGER trigger_comments_on_update ON comments"
    execute "DROP TRIGGER trigger_dmails_on_update ON dmails"
    execute "DROP TRIGGER trigger_forum_posts_on_update ON forum_posts"
    execute "DROP TRIGGER trigger_forum_topics_on_update ON forum_topics"
    execute "DROP TRIGGER trigger_notes_on_update ON notes"
    execute "DROP TRIGGER trigger_wiki_pages_on_update ON wiki_pages"
  end

  def down
    execute "CREATE TRIGGER trigger_comments_on_update BEFORE INSERT OR UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('body_index', 'pg_catalog.english', 'body')"
    execute "CREATE TRIGGER trigger_dmails_on_update BEFORE INSERT OR UPDATE ON public.dmails FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('message_index', 'pg_catalog.english', 'title', 'body')"
    execute "CREATE TRIGGER trigger_forum_posts_on_update BEFORE INSERT OR UPDATE ON public.forum_posts FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('text_index', 'pg_catalog.english', 'body')"
    execute "CREATE TRIGGER trigger_forum_topics_on_update BEFORE INSERT OR UPDATE ON public.forum_topics FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('text_index', 'pg_catalog.english', 'title')"
    execute "CREATE TRIGGER trigger_notes_on_update BEFORE INSERT OR UPDATE ON public.notes FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('body_index', 'pg_catalog.english', 'body')"
    execute "CREATE TRIGGER trigger_wiki_pages_on_update BEFORE INSERT OR UPDATE ON public.wiki_pages FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('body_index', 'pg_catalog.english', 'body', 'title')"
  end
end
