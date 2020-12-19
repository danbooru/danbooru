class RenamePostReplacementAttributes < ActiveRecord::Migration[6.1]
  def change
    rename_column :post_replacements, :file_ext_was, :old_file_ext
    rename_column :post_replacements, :file_size_was, :old_file_size
    rename_column :post_replacements, :image_width_was, :old_image_width
    rename_column :post_replacements, :image_height_was, :old_image_height
    rename_column :post_replacements, :md5_was, :old_md5
  end
end
