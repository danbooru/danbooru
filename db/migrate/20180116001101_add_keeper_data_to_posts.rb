class AddKeeperDataToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :keeper_data, :text
  end
end
