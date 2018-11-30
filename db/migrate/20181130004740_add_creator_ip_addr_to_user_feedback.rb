class AddCreatorIpAddrToUserFeedback < ActiveRecord::Migration[5.2]
  def change
    add_column :user_feedback, :creator_ip_addr, "inet"
    add_index :user_feedback, :creator_ip_addr
  end
end
