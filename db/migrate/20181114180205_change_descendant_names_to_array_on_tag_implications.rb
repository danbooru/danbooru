class ChangeDescendantNamesToArrayOnTagImplications < ActiveRecord::Migration[5.2]
  def up
    TagImplication.without_timeout do
      add_column :tag_implications, :descendant_names_array, "text[]", default: "{}"
      execute "update tag_implications set descendant_names_array = string_to_array(descendant_names, ' ')::text[]"
      remove_column :tag_implications, :descendant_names
      rename_column :tag_implications, :descendant_names_array, :descendant_names
    end
  end

  def down
    TagImplication.without_timeout do
      change_column :tag_implications, :descendant_names, "text", using: "array_to_string(descendant_names, ' ')", default: nil
    end
  end
end
