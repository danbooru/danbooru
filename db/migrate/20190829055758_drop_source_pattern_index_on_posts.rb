# see db/migrate/20130328092739_change_source_pattern_index_on_posts.rb

class DropSourcePatternIndexOnPosts < ActiveRecord::Migration[6.0]
  def up
    execute "set statement_timeout = 0"

    execute "DROP INDEX index_posts_on_source_pattern"
    execute "DROP FUNCTION SourcePattern(text)"
    add_index :posts, "lower(source) gin_trgm_ops", name: "index_posts_on_source_trgm", using: :gin, where: "source != ''"
  end

  def down
    execute "set statement_timeout = 0"

    remove_index :posts, name: "index_posts_on_source_trgm"
    execute "CREATE FUNCTION SourcePattern(src text) RETURNS text AS $$
               BEGIN
                 RETURN regexp_replace(src, '^[^/]*(//)?[^/]*\.pixiv\.net/img.*(/[^/]*/[^/]*)$', E'pixiv\\\\2');
               END;
             $$ LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT"
    execute "CREATE INDEX index_posts_on_source_pattern ON posts USING btree
             ((SourcePattern(source)) text_pattern_ops)"
  end
end
