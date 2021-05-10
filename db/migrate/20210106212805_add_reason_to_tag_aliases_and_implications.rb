class AddReasonToTagAliasesAndImplications < ActiveRecord::Migration[6.1]
  def change
    add_column :tag_aliases, :reason, :text, null: false, default: "", if_not_exists: true
    add_column :tag_implications, :reason, :text, null: false, default: "", if_not_exists: true
  end
end
