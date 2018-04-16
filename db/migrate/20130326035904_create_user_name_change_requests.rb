class CreateUserNameChangeRequests < ActiveRecord::Migration[4.2]
  def up
    create_table :user_name_change_requests do |t|
      t.string :status, :null => false, :default => "pending"
      t.integer :user_id, :null => false
      t.integer :approver_id
      t.string :original_name
      t.string :desired_name
      t.text :change_reason
      t.text :rejection_reason
      t.timestamps
    end
    
    add_index :user_name_change_requests, :user_id
    add_index :user_name_change_requests, :original_name
  end

  def down
    drop_table :user_name_change_requests
  end
end
