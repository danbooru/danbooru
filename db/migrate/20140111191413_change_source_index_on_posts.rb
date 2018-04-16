class ChangeSourceIndexOnPosts < ActiveRecord::Migration[4.2]
  def up
    execute "set statement_timeout = 0"
    execute "DROP INDEX index_posts_on_source"
    execute "DROP INDEX index_posts_on_source_pattern"
    execute "CREATE INDEX index_posts_on_source ON posts USING btree
             (lower(source))"
    execute "CREATE INDEX index_posts_on_source_pattern ON posts USING btree
             ((SourcePattern(lower(source))) text_pattern_ops)"
  end

  def down
    execute "set statement_timeout = 0"
    execute "DROP INDEX index_posts_on_source"
    execute "DROP INDEX index_posts_on_source_pattern"
    execute "CREATE INDEX index_posts_on_source ON posts USING btree
             (source)"
    execute "CREATE INDEX index_posts_on_source_pattern ON posts USING btree
             ((SourcePattern(source)) text_pattern_ops)"
  end
end
