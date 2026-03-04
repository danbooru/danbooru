class ReplacePixivIdWithSourceSiteAndSourceIdOnPosts < ActiveRecord::Migration[7.0]
  def up
    execute "set statement_timeout = 0"

    add_column :posts, :site_name, :string
    add_column :posts, :site_id, :string

    execute <<~SQL
      UPDATE posts
      SET site_name = 'Pixiv', site_id = pixiv_id::varchar
      WHERE pixiv_id IS NOT NULL
    SQL

    remove_index :posts, name: :index_posts_on_pixiv_id
    remove_column :posts, :pixiv_id

    execute <<~SQL
      CREATE INDEX index_posts_on_site_name
      ON posts (lower(site_name))
      WHERE site_name IS NOT NULL
    SQL

    execute <<~SQL
      CREATE INDEX index_posts_on_site_name_and_site_id
      ON posts (lower(site_name), site_id)
      WHERE site_name IS NOT NULL AND site_id IS NOT NULL
    SQL

    execute <<~SQL
      CREATE INDEX index_posts_on_site_name_and_site_id_bigint
      ON posts (lower(site_name), (site_id::bigint))
      WHERE site_name IS NOT NULL AND site_id ~ '^[0-9]{1,19}$' AND site_id <= '9223372036854775807'
    SQL
  end

  def down
    execute "set statement_timeout = 0"

    remove_index :posts, name: :index_posts_on_site_name
    remove_index :posts, name: :index_posts_on_site_name_and_site_id
    remove_index :posts, name: :index_posts_on_site_name_and_site_id_bigint

    add_column :posts, :pixiv_id, :integer

    execute <<~SQL
      UPDATE posts
      SET pixiv_id = site_id::integer
      WHERE site_name = 'Pixiv' AND site_id ~ '^\\d+$'
    SQL

    remove_column :posts, :site_name
    remove_column :posts, :site_id

    add_index :posts, :pixiv_id, where: "pixiv_id IS NOT NULL", name: :index_posts_on_pixiv_id
  end
end
