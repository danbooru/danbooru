class CreateAIMetadata < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_metadata do |t|
      t.references :post, index: { unique: true }
      t.text :prompt
      t.text :negative_prompt
      t.string :sampler
      t.bigint :seed
      t.integer :steps
      t.float :cfg_scale
      t.string :model_hash
      t.timestamps
    end
  end
end
