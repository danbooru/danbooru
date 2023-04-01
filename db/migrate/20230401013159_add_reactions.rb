class AddReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :reactions, id: :integer do |t|
      t.timestamps
      t.integer :creator_id, null: false
      t.integer :reaction_id, null: false
      t.references :model, type: :integer, polymorphic: true, null: false
    end

    add_index :reactions, :creator_id
    add_index :reactions, [:model_type, :model_id, :creator_id, :reaction_id], name: "index_reactions_on_model_creator_reaction", unique: true
  end
end
