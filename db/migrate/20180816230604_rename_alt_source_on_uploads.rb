class RenameAltSourceOnUploads < ActiveRecord::Migration[5.2]
  def change
    rename_column :uploads, :alt_source, :referer_url
  end
end
