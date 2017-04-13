class AddTitleToBulkUpdateRequests < ActiveRecord::Migration
  def change
  	add_column :bulk_update_requests, :title, :text
  end
end
