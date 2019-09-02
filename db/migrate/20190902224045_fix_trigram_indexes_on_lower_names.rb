class FixTrigramIndexesOnLowerNames < ActiveRecord::Migration[6.0]
  def up
    remove_index :posts, name: "index_posts_on_source_trgm"
    add_index :posts, "source gin_trgm_ops", name: "index_posts_on_source_trgm", using: :gin

    remove_index :users, name: "index_users_on_name_trgm"
    add_index :users, "name gin_trgm_ops", name: "index_users_on_name_trgm", using: :gin

    remove_index :pools, name: "index_pools_on_name_trgm"
    add_index :pools, "name gin_trgm_ops", name: "index_pools_on_name_trgm", using: :gin
  end

  def down
    remove_index :posts, name: "index_posts_on_source_trgm"
    add_index :posts, "lower(source) gin_trgm_ops", name: "index_posts_on_source_trgm", using: :gin, where: "source != ''"

    remove_index :users, name: "index_users_on_name_trgm"
    add_index :users, "lower(name) gin_trgm_ops", name: "index_users_on_name_trgm", using: :gin

    remove_index :pools, name: "index_pools_on_name_trgm"
    add_index :pools, "lower(name) gin_trgm_ops", name: "index_pools_on_name_trgm", using: :gin
  end
end
