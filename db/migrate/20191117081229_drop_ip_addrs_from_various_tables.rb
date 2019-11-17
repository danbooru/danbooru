class DropIpAddrsFromVariousTables < ActiveRecord::Migration[6.0]
  def change
    remove_index :post_appeals, :creator_ip_addr
    remove_index :post_flags, :creator_ip_addr
    remove_index :user_feedback, :creator_ip_addr

    remove_column :post_appeals, :creator_ip_addr, :inet
    remove_column :post_flags, :creator_ip_addr, :inet, null: false
    remove_column :tag_aliases, :creator_ip_addr, :inet, null: false
    remove_column :tag_implications, :creator_ip_addr, :inet, null: false
    remove_column :user_feedback, :creator_ip_addr, :inet
  end
end
