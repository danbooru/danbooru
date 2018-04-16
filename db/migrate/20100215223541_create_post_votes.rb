class CreatePostVotes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :post_votes do |t|
      t.column :post_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :score, :integer, :null => false
      t.timestamps
    end

    add_index :post_votes, :post_id
    add_index :post_votes, :user_id
  end

  def self.down
    drop_table :post_votes
  end
end
