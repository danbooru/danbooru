class AddKeeperDataToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :keeper_data, :text
  end
end
