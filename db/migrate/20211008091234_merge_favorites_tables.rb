require_relative "20100211181944_create_favorites.rb"

class MergeFavoritesTables < ActiveRecord::Migration[6.1]
  def up
    execute "set statement_timeout = 0"

    execute "CREATE TABLE favorites_copy AS SELECT id, user_id, post_id FROM favorites"
    revert CreateFavorites
    rename_table :favorites_copy, :favorites

    add_index :favorites, [:user_id, :post_id], unique: true, if_not_exists: true
    add_index :favorites, [:user_id, :id], if_not_exists: true
    add_index :favorites, :post_id, if_not_exists: true
    change_column_null :favorites, :user_id, false
    change_column_null :favorites, :post_id, false

    execute "ALTER TABLE favorites ADD PRIMARY KEY (id)"
    max_id = Favorite.maximum(:id).to_i
    execute "CREATE SEQUENCE IF NOT EXISTS favorites_id_seq START #{max_id+1} OWNED BY favorites.id"
    execute "ALTER TABLE favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq')"
  end

  def down
    execute "set statement_timeout = 0"

    rename_table :favorites, :favorites_copy
    run CreateFavorites
    execute "INSERT INTO favorites(id, user_id, post_id) SELECT id, user_id, post_id FROM favorites_copy"
    drop_table :favorites_copy
  end
end
