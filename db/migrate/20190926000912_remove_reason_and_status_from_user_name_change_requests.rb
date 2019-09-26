class RemoveReasonAndStatusFromUserNameChangeRequests < ActiveRecord::Migration[6.0]
  def change
    remove_column :user_name_change_requests, :change_reason, :text
    remove_column :user_name_change_requests, :rejection_reason, :text
    remove_column :user_name_change_requests, :approver_id, :integer
    remove_column :user_name_change_requests, :status, :string, null: false, default: "pending"
  end
end
