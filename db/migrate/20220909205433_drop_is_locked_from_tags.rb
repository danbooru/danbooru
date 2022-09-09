class DropIsLockedFromTags < ActiveRecord::Migration[7.0]
  def change
    remove_column :tags, :is_locked, :boolean, default: false, null: false
  end
end
