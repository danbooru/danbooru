class CreateBulkUpdateRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :bulk_update_requests do |t|
      t.integer :user_id, :null => false
      t.integer :forum_topic_id
      t.text :script, :null => false
      t.string :status, :null => false, :default => "pending"

      t.timestamps
    end
  end
end
