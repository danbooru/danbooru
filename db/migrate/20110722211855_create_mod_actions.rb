class CreateModActions < ActiveRecord::Migration[4.2]
  def change
    create_table :mod_actions do |t|
      t.column :creator_id, :integer, :null => false
      t.column :description, :text, :null => false
      t.timestamps
    end
  end
end
