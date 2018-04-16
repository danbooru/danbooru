class AddApproverId < ActiveRecord::Migration[4.2]
  def change
    add_column :bulk_update_requests, :approver_id, :integer
    add_column :tag_aliases, :approver_id, :integer
    add_column :tag_implications, :approver_id, :integer
  end
end
