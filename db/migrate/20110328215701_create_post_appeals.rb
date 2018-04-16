class CreatePostAppeals < ActiveRecord::Migration[4.2]
  def self.up
    create_table :post_appeals do |t|
      t.column :post_id, :integer, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :creator_ip_addr, :integer, :null => false
      t.column :reason, :text
      t.timestamps
    end

    add_index :post_appeals, :post_id
    add_index :post_appeals, :creator_id
    add_index :post_appeals, :creator_ip_addr
  end

  def self.down
    drop_table :post_appeals
  end
end
