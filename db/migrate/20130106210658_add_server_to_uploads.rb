class AddServerToUploads < ActiveRecord::Migration[4.2]
  def change
    add_column :uploads, :server, :text
  end
end
