class DropKeeperDataFromPosts < ActiveRecord::Migration[6.0]
  def change
    remove_column :posts, :keeper_data, :text
  end
end
