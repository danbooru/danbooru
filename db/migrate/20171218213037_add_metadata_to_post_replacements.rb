class AddMetadataToPostReplacements < ActiveRecord::Migration[4.2]
  def change
    PostReplacement.without_timeout do
      add_column :post_replacements, :file_ext_was, :string
      add_column :post_replacements, :file_size_was, :integer
      add_column :post_replacements, :image_width_was, :integer
      add_column :post_replacements, :image_height_was, :integer
      add_column :post_replacements, :md5_was, :string

      add_column :post_replacements, :file_ext, :string
      add_column :post_replacements, :file_size, :integer
      add_column :post_replacements, :image_width, :integer
      add_column :post_replacements, :image_height, :integer
      add_column :post_replacements, :md5, :string
    end
  end
end
