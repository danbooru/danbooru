class AddTagIdAndScoreIndexToAITags < ActiveRecord::Migration[7.0]
  def change
    add_index :ai_tags, [:tag_id, :score], if_not_exists: true
    remove_index :ai_tags, :tag_id
  end
end
