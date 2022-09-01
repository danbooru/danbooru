# frozen_string_literal: true

class AddWordsToTags < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :tags, :words, :string, null: false, array: true, default: [], if_not_exists: true
    add_index :tags, "array_to_tsvector(words)", using: :gin, if_not_exists: true, algorithm: :concurrently
  end
end
