class CreatePostVotes < ActiveRecord::Migration
  def self.up
    create_table :post_votes do |t|
      t.column :post_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :score, :integer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :post_votes
  end
end
