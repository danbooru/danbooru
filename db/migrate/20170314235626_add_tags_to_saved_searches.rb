class AddTagsToSavedSearches < ActiveRecord::Migration
  def change
  	execute "set statement_timeout = 0"
  	add_column :saved_searches, :labels, "text", array: true, null: false, default: []
  	add_index :saved_searches, :labels, using: :gin
  	rename_column :saved_searches, :tag_query, :query
  end
end
