class DropDescendantNamesFromTagImplications < ActiveRecord::Migration[6.0]
  def change
    remove_column :tag_implications, :descendant_names, "text[]", default: "{}", null: false
  end
end
