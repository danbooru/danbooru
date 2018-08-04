class AddAltSourceToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :alt_source, :text
    add_index :uploads, :source
    add_index :uploads, :alt_source
  end
end
