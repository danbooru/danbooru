class CreateDtextLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :dtext_links do |t|
      t.timestamps
      t.references :model, polymorphic: true, null: false
      t.integer :link_type, null: false
      t.string :link_target, null: false

      t.index :link_type
      t.index :link_target, opclass: "text_pattern_ops"
    end
  end
end
