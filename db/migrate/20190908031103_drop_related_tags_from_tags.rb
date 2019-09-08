class DropRelatedTagsFromTags < ActiveRecord::Migration[6.0]
  def change
    remove_column :tags, :related_tags, :text
    remove_column :tags, :related_tags_updated_at, :datetime
  end
end
