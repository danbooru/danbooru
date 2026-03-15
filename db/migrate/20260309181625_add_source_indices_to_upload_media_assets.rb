class AddSourceIndicesToUploadMediaAssets < ActiveRecord::Migration[8.0]
  include MigrationHelpers
  disable_ddl_transaction!

  def change
    add_not_null_constraint :upload_media_assets, :user_id
    add_foreign_key :upload_media_assets, :users, deferrable: :deferred
    add_index :upload_media_assets, :user_id, algorithm: :concurrently

    remove_index :uploads, :source, algorithm: :concurrently
    remove_index :uploads, :referer_url, algorithm: :concurrently

    enable_extension "btree_gin"

    reversible do |dir|
      dir.up do
        execute "CREATE INDEX CONCURRENTLY index_uploads_on_uploader_id_and_source ON uploads USING gin (uploader_id, source gin_trgm_ops)"
        execute "CREATE INDEX CONCURRENTLY index_uploads_on_uploader_id_and_referer_url ON uploads USING gin (uploader_id, referer_url gin_trgm_ops)"
        execute "CREATE INDEX CONCURRENTLY index_upload_media_assets_on_user_id_and_source_url ON upload_media_assets USING gin (user_id, source_url gin_trgm_ops)"
      end

      dir.down do
        execute "DROP INDEX index_uploads_on_uploader_id_and_source"
        execute "DROP INDEX index_uploads_on_uploader_id_and_referer_url"
        execute "DROP INDEX index_upload_media_assets_on_user_id_and_source_url"
      end
    end
  end
end
