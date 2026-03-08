class ReplacePixivIdWithSourceSiteAndSourceIdOnPosts < ActiveRecord::Migration[7.0]
  def up
    execute "set statement_timeout = 0"

    add_column :posts, :source_name, :string
    add_column :posts, :source_id, :string
    add_column :posts, :source_id_num, :bigint

    execute <<~SQL
      CREATE INDEX index_posts_on_source_name
      ON posts (lower(source_name))
      WHERE source_name IS NOT NULL
    SQL

    execute <<~SQL
      CREATE INDEX index_posts_on_source_name_and_source_id
      ON posts (lower(source_name), source_id)
      WHERE source_name IS NOT NULL AND source_id IS NOT NULL
    SQL

    execute <<~SQL
      CREATE INDEX index_posts_on_source_name_and_source_id_num
      ON posts (lower(source_name), source_id_num)
      WHERE source_name IS NOT NULL AND source_id_num IS NOT NULL
    SQL
  end

  def down
    execute "set statement_timeout = 0"

    remove_index :posts, name: :index_posts_on_source_name
    remove_index :posts, name: :index_posts_on_source_name_and_source_id
    remove_index :posts, name: :index_posts_on_source_name_and_source_id_num

    remove_column :posts, :source_name
    remove_column :posts, :source_id
    remove_column :posts, :source_id_num
  end
end
