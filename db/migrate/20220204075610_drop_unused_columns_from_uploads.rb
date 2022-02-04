class DropUnusedColumnsFromUploads < ActiveRecord::Migration[7.0]
  def change
    remove_column :uploads, :file_path, :string
    remove_column :uploads, :content_type, :string
    remove_column :uploads, :rating, :character
    remove_column :uploads, :tag_string, :text
    remove_column :uploads, :backtrace, :text
    remove_column :uploads, :post_id, :integer
    remove_column :uploads, :md5_confirmation, :string
    remove_column :uploads, :server, :text
    remove_column :uploads, :parent_id, :integer
    remove_column :uploads, :md5, :string
    remove_column :uploads, :file_ext, :string
    remove_column :uploads, :file_size, :integer
    remove_column :uploads, :image_width, :integer
    remove_column :uploads, :image_height, :integer
    remove_column :uploads, :artist_commentary_desc, :text
    remove_column :uploads, :artist_commentary_title, :text
    remove_column :uploads, :include_artist_commentary, :boolean
    remove_column :uploads, :context, :text
    remove_column :uploads, :translated_commentary_title, :text
    remove_column :uploads, :translated_commentary_desc, :text
  end
end
