class AddApproverId < ActiveRecord::Migration
  def change
    add_column :bulk_update_requests, :approver_id, :integer
    add_column :tag_aliases, :approver_id, :integer
    add_column :tag_implications, :approver_id, :integer
  end
end
