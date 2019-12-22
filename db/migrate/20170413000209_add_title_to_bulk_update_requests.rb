class AddTitleToBulkUpdateRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :bulk_update_requests, :title, :text
  end
end
