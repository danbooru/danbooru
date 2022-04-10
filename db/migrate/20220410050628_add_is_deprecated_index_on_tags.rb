class AddIsDeprecatedIndexOnTags < ActiveRecord::Migration[7.0]
  def change
    add_index :tags, :is_deprecated, where: "is_deprecated = TRUE"
  end
end
