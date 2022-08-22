class AddTagIdAndScoreIndexToAITags < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :ai_tags, [:tag_id, :score], if_not_exists: true
    remove_index :ai_tags, :tag_id, algorithm: :concurrently, if_exists: true
  end
end
