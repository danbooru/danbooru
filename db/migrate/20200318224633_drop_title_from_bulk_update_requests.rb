class DropTitleFromBulkUpdateRequests < ActiveRecord::Migration[6.0]
  def change
    remove_column :bulk_update_requests, :title, :text
  end
end
