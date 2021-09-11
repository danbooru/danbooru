class CreateMediaMetadata < ActiveRecord::Migration[6.1]
  def change
    create_table :media_metadata do |t|
      t.timestamps null: false

      t.references :media_asset, null: false, index: { unique: true }
      t.jsonb :metadata, null: false, default: '{}'
      t.index :metadata, using: "gin"
    end

    reversible do |dir|
      dir.up do
        execute "INSERT INTO media_metadata (created_at, updated_at, media_asset_id, metadata) SELECT created_at, updated_at, id, '{}' FROM media_assets ORDER BY id ASC"
      end
    end
  end
end
