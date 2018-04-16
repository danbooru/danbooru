class CreatePostDisapprovals < ActiveRecord::Migration[4.2]
  def self.up
    create_table :post_disapprovals do |t|
      t.column :user_id, :integer, :null => false
      t.column :post_id, :integer, :null => false
      t.timestamps
    end

    add_index :post_disapprovals, :user_id
    add_index :post_disapprovals, :post_id
  end

  def self.down
    drop_table :post_disapprovals
  end
end
