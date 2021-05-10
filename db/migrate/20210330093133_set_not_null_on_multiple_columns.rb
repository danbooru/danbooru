class SetNotNullOnMultipleColumns < ActiveRecord::Migration[6.1]
  def change
    change_column_null :bans, :user_id, false
    change_column_null :dmails, :is_spam, false
    change_column_null :forum_topic_visits, :user_id, false
    change_column_null :forum_topic_visits, :forum_topic_id, false
    change_column_null :forum_topic_visits, :last_read_at, false
    change_column_null :mod_actions, :category, false
    change_column_null :pixiv_ugoira_frame_data, :post_id, false
    change_column_null :pools, :name, false
    change_column_null :post_appeals, :reason, false
    change_column_null :post_flags, :reason, false
    change_column_null :posts, :image_width, false
    change_column_null :posts, :image_height, false
    change_column_null :saved_searches, :user_id, false
    change_column_null :saved_searches, :query, false
    change_column_null :user_name_change_requests, :original_name, false
    change_column_null :user_name_change_requests, :desired_name, false
    change_column_null :users, :bcrypt_password_hash, false
  end
end
