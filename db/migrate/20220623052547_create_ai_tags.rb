class CreateAITags < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_tags, id: false do |t|
      t.column :media_asset_id, :integer, null: false
      t.column :tag_id, :integer, null: false
      t.column :score, :smallint, null: false

      t.index :media_asset_id
      t.index :tag_id
      t.index :score
    end
  end
end
