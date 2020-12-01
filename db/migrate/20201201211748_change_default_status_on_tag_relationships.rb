class ChangeDefaultStatusOnTagRelationships < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:tag_aliases, :status, from: "pending", to: "active")
    change_column_default(:tag_implications, :status, from: "pending", to: "active")
  end
end
