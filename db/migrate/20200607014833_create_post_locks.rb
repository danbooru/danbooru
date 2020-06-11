class CreatePostLocks < ActiveRecord::Migration[6.0]
  def change
    create_table :post_locks do |t|
      t.timestamps
      t.integer :post_id, null: false
      t.integer :bit_flags, null: false, default: 0
      t.integer :bit_changes, null: false, default: 0
      t.boolean :duration_set, null: false, default: false
      t.text :reason, null: false
      t.integer :creator_id, null: false
      t.integer :min_level, null: false
      t.boolean :level_set, null: false, default: false
      t.datetime :expires_at, null: false
    end

    add_index :post_locks, :creator_id
    add_index :post_locks, :post_id
  end
end
