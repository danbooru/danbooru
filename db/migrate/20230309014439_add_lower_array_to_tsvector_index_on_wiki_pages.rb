class AddLowerArrayToTsvectorIndexOnWikiPages < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :wiki_pages, "array_to_tsvector(lower(other_names))", using: :gin, algorithm: :concurrently, if_not_exists: true
  end
end
