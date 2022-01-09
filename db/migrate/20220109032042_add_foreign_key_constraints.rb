class AddForeignKeyConstraints < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :api_keys, :users, validate: false, deferrable: :deferred
    add_foreign_key :artist_commentaries, :posts, validate: false, deferrable: :deferred
    add_foreign_key :artist_commentary_versions, :posts, validate: false, deferrable: :deferred
    add_foreign_key :artist_commentary_versions, :users, column: :updater_id, validate: false, deferrable: :deferred
    add_foreign_key :artist_urls, :artists, validate: false, deferrable: :deferred
    add_foreign_key :artist_versions, :artists, validate: false, deferrable: :deferred
    add_foreign_key :artist_versions, :users, column: :updater_id, validate: false, deferrable: :deferred
    add_foreign_key :bans, :users, validate: false, deferrable: :deferred
    add_foreign_key :bans, :users, column: :banner_id, validate: false, deferrable: :deferred
    add_foreign_key :bulk_update_requests, :forum_posts, validate: false, deferrable: :deferred
    add_foreign_key :bulk_update_requests, :forum_topics, validate: false, deferrable: :deferred
    add_foreign_key :bulk_update_requests, :users, validate: false, deferrable: :deferred
    add_foreign_key :bulk_update_requests, :users, column: :approver_id, validate: false, deferrable: :deferred
    add_foreign_key :comments, :posts, validate: false, deferrable: :deferred
    add_foreign_key :comments, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :comments, :users, column: :updater_id, validate: false, deferrable: :deferred
    add_foreign_key :comment_votes, :users, validate: false, deferrable: :deferred
    add_foreign_key :comment_votes, :comments, validate: false, deferrable: :deferred
    add_foreign_key :dmails, :users, column: :owner_id, validate: false, deferrable: :deferred
    add_foreign_key :dmails, :users, column: :from_id, validate: false, deferrable: :deferred
    add_foreign_key :dmails, :users, column: :to_id, validate: false, deferrable: :deferred
    add_foreign_key :email_addresses, :users, validate: false, deferrable: :deferred
    add_foreign_key :favorite_groups, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :favorites, :posts, validate: false, deferrable: :deferred
    add_foreign_key :favorites, :users, validate: false, deferrable: :deferred
    add_foreign_key :forum_post_votes, :forum_posts, validate: false, deferrable: :deferred
    add_foreign_key :forum_post_votes, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :forum_posts, :forum_topics, column: :topic_id, validate: false, deferrable: :deferred
    add_foreign_key :forum_posts, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :forum_posts, :users, column: :updater_id, validate: false, deferrable: :deferred
    add_foreign_key :forum_topic_visits, :users, validate: false, deferrable: :deferred
    add_foreign_key :forum_topic_visits, :forum_topics, validate: false, deferrable: :deferred
    add_foreign_key :forum_topics, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :forum_topics, :users, column: :updater_id, validate: false, deferrable: :deferred
    add_foreign_key :posts, :users, column: :uploader_id, validate: false, deferrable: :deferred
    add_foreign_key :posts, :users, column: :approver_id, validate: false, deferrable: :deferred
    add_foreign_key :posts, :posts, column: :parent_id, validate: false, deferrable: :deferred
    add_foreign_key :ip_bans, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :media_metadata, :media_assets, validate: false, deferrable: :deferred
    add_foreign_key :mod_actions, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :moderation_reports, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :news_updates, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :news_updates, :users, column: :updater_id, validate: false, deferrable: :deferred
    add_foreign_key :notes, :posts, validate: false, deferrable: :deferred
    add_foreign_key :note_versions, :posts, validate: false, deferrable: :deferred
    add_foreign_key :note_versions, :notes, validate: false, deferrable: :deferred
    add_foreign_key :note_versions, :users, column: :updater_id, validate: false, deferrable: :deferred
    add_foreign_key :pixiv_ugoira_frame_data, :posts, validate: false, deferrable: :deferred
    add_foreign_key :post_appeals, :posts, validate: false, deferrable: :deferred
    add_foreign_key :post_appeals, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :post_approvals, :posts, validate: false, deferrable: :deferred
    add_foreign_key :post_approvals, :users, validate: false, deferrable: :deferred
    add_foreign_key :post_disapprovals, :posts, validate: false, deferrable: :deferred
    add_foreign_key :post_disapprovals, :users, validate: false, deferrable: :deferred
    add_foreign_key :post_flags, :posts, validate: false, deferrable: :deferred
    add_foreign_key :post_flags, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :post_replacements, :posts, validate: false, deferrable: :deferred
    add_foreign_key :post_replacements, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :post_votes, :posts, validate: false, deferrable: :deferred
    add_foreign_key :post_votes, :users, validate: false, deferrable: :deferred
    add_foreign_key :saved_searches, :users, validate: false, deferrable: :deferred
    add_foreign_key :tag_aliases, :forum_posts, validate: false, deferrable: :deferred
    add_foreign_key :tag_aliases, :forum_topics, validate: false, deferrable: :deferred
    add_foreign_key :tag_aliases, :users, column: :approver_id, validate: false, deferrable: :deferred
    add_foreign_key :tag_aliases, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :tag_implications, :forum_posts, validate: false, deferrable: :deferred
    add_foreign_key :tag_implications, :forum_topics, validate: false, deferrable: :deferred
    add_foreign_key :tag_implications, :users, column: :approver_id, validate: false, deferrable: :deferred
    add_foreign_key :tag_implications, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :uploads, :posts, validate: false, deferrable: :deferred
    add_foreign_key :uploads, :posts, column: :parent_id, validate: false, deferrable: :deferred
    add_foreign_key :uploads, :users, column: :uploader_id, validate: false, deferrable: :deferred
    add_foreign_key :users, :users, column: :inviter_id, validate: false, deferrable: :deferred
    add_foreign_key :user_events, :users, validate: false, deferrable: :deferred
    add_foreign_key :user_events, :user_sessions, validate: false, deferrable: :deferred
    add_foreign_key :user_feedback, :users, validate: false, deferrable: :deferred
    add_foreign_key :user_feedback, :users, column: :creator_id, validate: false, deferrable: :deferred
    add_foreign_key :user_name_change_requests, :users, validate: false, deferrable: :deferred
    add_foreign_key :user_upgrades, :users, column: :recipient_id, validate: false, deferrable: :deferred
    add_foreign_key :user_upgrades, :users, column: :purchaser_id, validate: false, deferrable: :deferred
    add_foreign_key :wiki_page_versions, :users, column: :updater_id, validate: false, deferrable: :deferred
    add_foreign_key :wiki_page_versions, :wiki_pages, validate: false, deferrable: :deferred
  end
end
