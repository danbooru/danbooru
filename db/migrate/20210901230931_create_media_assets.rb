class CreateMediaAssets < ActiveRecord::Migration[6.1]
  def change
    create_table :media_assets do |t|
      t.timestamps null: false, index: true

      t.string :md5, null: false, index: true, unique: true
      t.string :file_ext, null: false, index: true
      t.integer :file_size, null: false, index: true
      t.integer :image_width, null: false, index: true
      t.integer :image_height, null: false, index: true
    end

    reversible do |dir|
      dir.up do
        execute "INSERT INTO media_assets (created_at, updated_at, md5, file_ext, file_size, image_width, image_height) SELECT created_at, created_at AS updated_at, md5, file_ext, file_size, image_width, image_height FROM posts ORDER BY id ASC"
      end
    end
  end
end
