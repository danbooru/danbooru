class CreateForumPostVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :forum_post_votes do |t|
      t.integer :forum_post_id, null: false
      t.integer :creator_id, null: false
      t.integer :score, null: false

      t.timestamps
    end

    add_index :forum_post_votes, :forum_post_id
    add_index :forum_post_votes, [:forum_post_id, :creator_id], unique: true
  end
end
