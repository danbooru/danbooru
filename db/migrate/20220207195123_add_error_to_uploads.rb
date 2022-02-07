class AddErrorToUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :uploads, :error, :text
    add_index :uploads, :error, where: "error IS NOT NULL"
  end
end
