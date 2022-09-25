class AddSubjectToModActions < ActiveRecord::Migration[7.0]
  def change
    add_column :mod_actions, :subject_type, :string, null: true
    add_column :mod_actions, :subject_id, :integer, null: true

    add_index :mod_actions, :subject_type
    add_index :mod_actions, :subject_id
  end
end
