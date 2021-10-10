class AddStringToArrayTagStringIndexOnPosts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :posts, "string_to_array(tag_string, ' ')", using: :gin, algorithm: :concurrently

    up_only do
      # Set the statistics target on the index to 3000 so that Postgres will a)
      # collect stats on the size of top 3000 largest tags and b) sample
      # 3000*300 = 900k random posts to do so. This is necessary so that
      # Postgres can generate good query plans based on the size of the tag.
      #
      # https://akorotkov.github.io/blog/2017/05/31/alter-index-weird/
      # https://www.postgresql.org/docs/current/planner-stats.html
      # https://www.postgresql.org/docs/current/sql-alterindex.html
      execute "ALTER INDEX index_posts_on_string_to_array_tag_string ALTER COLUMN 1 SET STATISTICS 3000"
      execute "VACUUM (VERBOSE, ANALYZE) posts"
    end
  end
end
