class AddServerToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :server, :text
  end
end
