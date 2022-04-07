class AddIsDeprecatedToTags < ActiveRecord::Migration[7.0]
  def change
    ApplicationRecord.without_timeout do
      add_column :tags, :is_deprecated, :boolean, null: false, default: false
    end
  end
end
