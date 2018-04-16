class AddIndexPixivOnPosts < ActiveRecord::Migration[4.2]
  def up
    execute "set statement_timeout = 0"
    execute "CREATE INDEX index_posts_on_pixiv_suffix ON posts USING btree
             ((substring(source, 'pixiv.net/img.*/([^/]*/[^/]*)$')) text_pattern_ops);"
    execute "CREATE INDEX index_posts_on_pixiv_id ON posts USING btree
             ((substring(source, 'pixiv.net/img.*/([0-9]+)[^/]*$')::integer));"
  end

  def down
    execute "set statement_timeout = 0"
    execute "DROP INDEX index_posts_on_pixiv_suffix;"
    execute "DROP INDEX index_posts_on_pixiv_id;"
  end
end
