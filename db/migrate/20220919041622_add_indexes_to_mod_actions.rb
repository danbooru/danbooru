class AddIndexesToModActions < ActiveRecord::Migration[7.0]
  def change
    add_index :mod_actions, :category
    add_index :mod_actions, :description, using: :gin, opclass: :gin_trgm_ops
    add_index :mod_actions, "to_tsvector('pg_catalog.english', description)", using: :gin
  end
end
