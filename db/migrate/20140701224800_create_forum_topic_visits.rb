class CreateForumTopicVisits < ActiveRecord::Migration[4.2]
  def change
    create_table :forum_topic_visits do |t|
      t.integer :user_id
      t.integer :forum_topic_id
      t.timestamp :last_read_at

      t.timestamps
    end

    add_index :forum_topic_visits, :user_id
    add_index :forum_topic_visits, :forum_topic_id
    add_index :forum_topic_visits, :last_read_at
  end
end
