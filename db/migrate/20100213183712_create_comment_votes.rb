class CreateCommentVotes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :comment_votes do |t|
      t.column :comment_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :score, :integer, :null => false
      t.timestamps
    end

    add_index :comment_votes, :comment_id
    add_index :comment_votes, :user_id
    add_index :comment_votes, :created_at
  end

  def self.down
    drop_table :comment_votes
  end
end
