class ChangeDescendantNamesToArrayOnTagImplications < ActiveRecord::Migration[5.2]
  def up
    TagImplication.without_timeout do
      change_column_default :tag_implications, :descendant_names, from: '', to: false
      change_column :tag_implications, :descendant_names, "text[]", using: "string_to_array(descendant_names, ' ')::text[]", default: "{}"
    end
  end

  def down
    TagImplication.without_timeout do
      change_column :tag_implications, :descendant_names, "text", using: "array_to_string(descendant_names, ' ')", default: nil
    end
  end
end
