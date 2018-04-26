class CreateForumSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :forum_subscriptions do |t|
      t.integer :user_id
      t.integer :forum_topic_id
      t.datetime :last_read_at
      t.string :delete_key
    end

    add_index :forum_subscriptions, :user_id
    add_index :forum_subscriptions, :forum_topic_id
  end
end
