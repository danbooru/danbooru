class AddMissingFieldsToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :md5, :string
    add_column :uploads, :file_ext, :string
    add_column :uploads, :file_size, :integer
    add_column :uploads, :image_width, :integer
    add_column :uploads, :image_height, :integer
    add_column :uploads, :artist_commentary_desc, :text
    add_column :uploads, :artist_commentary_title, :text
    add_column :uploads, :include_artist_commentary, :boolean
  end
end
