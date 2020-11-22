class CreatePostRegenerations < ActiveRecord::Migration[6.0]
  def change
    create_table :post_regenerations do |t|
      t.timestamps
      t.integer :creator_id, null: false
      t.integer :post_id, null: false
      t.string :category, null: false

      t.index :creator_id
      t.index :post_id
    end
  end
end
