class CreateAIMetadataVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_metadata_versions do |t|
      t.references :ai_metadata, null: false
      t.references :post, null: false
      t.references :updater, null: false, foreign_key: { to_table: :users }
      t.references :previous_version, null: true, foreign_key: { to_table: :ai_metadata_versions }

      t.integer :version, null: false
      t.text :prompt
      t.text :negative_prompt
      t.string :sampler
      t.bigint :seed
      t.integer :steps
      t.float :cfg_scale
      t.string :model_hash

      t.timestamps

      t.index [:ai_metadata_id, :previous_version_id], unique: true, name: "idx_ai_metadata_versions_on_metadata_id_and_prev_id"
    end
  end
end
