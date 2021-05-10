class AddTagsToBulkUpdateRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :bulk_update_requests, :tags, "text[]", default: "{}", null: false
    add_index :bulk_update_requests, :tags, using: :gin
  end
end
