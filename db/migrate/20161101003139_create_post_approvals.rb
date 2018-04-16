class CreatePostApprovals < ActiveRecord::Migration[4.2]
  def change
    create_table :post_approvals do |t|
    	t.integer :user_id, null: false
    	t.integer :post_id, null: false
      t.timestamps null: false
    end

    add_index :post_approvals, :user_id
    add_index :post_approvals, :post_id
  end
end
