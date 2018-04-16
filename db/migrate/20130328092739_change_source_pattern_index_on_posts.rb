class ChangeSourcePatternIndexOnPosts < ActiveRecord::Migration[4.2]
  def up
    execute "set statement_timeout = 0"
    execute "DROP INDEX index_posts_on_pixiv_suffix"
    execute "DROP INDEX index_posts_on_source_pattern"
    execute "CREATE FUNCTION SourcePattern(src text) RETURNS text AS $$
               BEGIN
                 RETURN regexp_replace(src, '^[^/]*(//)?[^/]*\.pixiv\.net/img.*(/[^/]*/[^/]*)$', E'pixiv\\\\2');
               END;
             $$ LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT"
    execute "CREATE INDEX index_posts_on_source_pattern ON posts USING btree
             ((SourcePattern(source)) text_pattern_ops)"
    # execute "CREATE INDEX index_posts_on_pixiv_id ON posts USING btree
    #          ((substring(source, 'pixiv.net/img.*/([0-9]+)[^/]*$')::integer))"
  end

  def down
    execute "set statement_timeout = 0"
    execute "DROP INDEX index_posts_on_source_pattern"
    execute "DROP FUNCTION SourcePattern(text)"
    execute "CREATE INDEX index_posts_on_source_pattern ON posts USING btree
             (source text_pattern_ops)"
    execute "CREATE INDEX index_posts_on_pixiv_suffix ON posts USING btree
             ((substring(source, 'pixiv.net/img.*/([^/]*/[^/]*)$')) text_pattern_ops)"
    # execute "DROP INDEX index_posts_on_pixiv_id"
  end
end
