class DropTestParser < ActiveRecord::Migration[6.1]
  def up
    execute "DROP INDEX index_posts_on_tag_index"
    execute "DROP TRIGGER trigger_posts_on_tag_index_update ON posts"
    execute "DROP TEXT SEARCH CONFIGURATION danbooru"
    execute "DROP TEXT SEARCH PARSER testparser"
    execute "DROP FUNCTION IF EXISTS testprs_start"
    execute "DROP FUNCTION IF EXISTS testprs_end"
    execute "DROP FUNCTION IF EXISTS testprs_getlexeme"
    execute "DROP FUNCTION IF EXISTS testprs_lextype"
  end

  def down
    execute "CREATE OR REPLACE FUNCTION testprs_start(internal, int4)
    RETURNS internal
    AS '$libdir/test_parser'
    LANGUAGE C STRICT"

    execute "CREATE OR REPLACE FUNCTION testprs_getlexeme(internal, internal, internal)
    RETURNS internal
    AS '$libdir/test_parser'
    LANGUAGE C STRICT"

    execute "CREATE OR REPLACE FUNCTION testprs_end(internal)
    RETURNS void
    AS '$libdir/test_parser'
    LANGUAGE C STRICT"

    execute "CREATE OR REPLACE FUNCTION testprs_lextype(internal)
    RETURNS internal
    AS '$libdir/test_parser'
    LANGUAGE C STRICT"

    execute "CREATE TEXT SEARCH PARSER testparser (
      START    = testprs_start,
      GETTOKEN = testprs_getlexeme,
      END      = testprs_end,
      HEADLINE = pg_catalog.prsd_headline,
      LEXTYPES = testprs_lextype
    )"

    execute "CREATE TEXT SEARCH CONFIGURATION public.danbooru (PARSER = public.testparser)"
    execute "ALTER TEXT SEARCH CONFIGURATION public.danbooru ADD MAPPING FOR WORD WITH SIMPLE"
    execute "CREATE TRIGGER trigger_posts_on_tag_index_update BEFORE INSERT OR UPDATE ON posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string')"
    execute "CREATE INDEX index_posts_on_tag_index ON posts USING gin (tag_index)"
  end
end
