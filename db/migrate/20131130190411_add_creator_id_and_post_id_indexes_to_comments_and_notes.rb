class AddCreatorIdAndPostIdIndexesToCommentsAndNotes < ActiveRecord::Migration[4.2]
  def self.up
    execute "set statement_timeout = 0"
    remove_index :comments, :creator_id
    remove_index :notes, :creator_id
    add_index :comments, [:creator_id, :post_id]
    add_index :notes, [:creator_id, :post_id]
  end

  def self.down
    execute "set statement_timeout = 0"
    remove_index :comments, [:creator_id, :post_id]
    remove_index :notes, [:creator_id, :post_id]
    add_index :comments, :creator_id
    add_index :notes, :creator_id
  end
end
