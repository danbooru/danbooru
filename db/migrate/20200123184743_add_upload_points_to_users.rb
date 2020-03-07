class AddUploadPointsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :upload_points, :integer, null: false, default: 1000
  end
end
