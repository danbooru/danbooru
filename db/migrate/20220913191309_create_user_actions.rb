class CreateUserActions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_view :user_actions

    add_index :bans, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :bulk_update_requests, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :dmails, :created_at, algorithm: :concurrently, where: "owner_id = from_id", name: "index_sent_dmails_on_created_at", if_not_exists: true
    add_index :favorite_groups, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :forum_posts, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :forum_post_votes, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :forum_topics, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :moderation_reports, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :post_approvals, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :post_disapprovals, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :post_flags, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :post_replacements, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :saved_searches, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :tag_aliases, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :tag_implications, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :tag_versions, :created_at, algorithm: :concurrently, where: "updater_id IS NOT NULL", name: "index_tag_versions_on_created_at_where_updater_id_is_not_null", if_not_exists: true
    add_index :users, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :user_events, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :user_feedback, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :uploads, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :user_upgrades, :created_at, algorithm: :concurrently, where: "status IN (20, 30)", name: "index_completed_user_upgrades_on_created_at", if_not_exists: true
    add_index :user_name_change_requests, :created_at, algorithm: :concurrently, if_not_exists: true

    add_index :artist_versions, [:updater_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :artist_commentary_versions, [:updater_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :bans, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :bulk_update_requests, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :comments, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :comment_votes, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :dmails, [:owner_id, :created_at], algorithm: :concurrently, where: "owner_id = from_id", name: "index_sent_dmails_on_owner_id_and_created_at", if_not_exists: true
    add_index :favorite_groups, [:created_at, :id, :is_public, :creator_id], algorithm: :concurrently, name: "index_favorite_groups_on_created_at_id_is_public_creator_id", if_not_exists: true
    add_index :forum_posts, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :forum_post_votes, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :forum_topics, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :mod_actions, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :moderation_reports, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :note_versions, [:updater_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :posts, [:uploader_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :post_appeals, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :post_approvals, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :post_disapprovals, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :post_flags, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :post_replacements, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :post_votes, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :saved_searches, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :tag_aliases, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :tag_implications, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :tag_versions, [:updater_id, :created_at], algorithm: :concurrently, where: "updater_id IS NOT NULL", name: "index_tag_versions_on_updater_id_and_created_at", if_not_exists: true
    add_index :uploads, [:uploader_id, :created_at, :id], algorithm: :concurrently, if_not_exists: true
    add_index :users, [:id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :user_events, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :user_feedback, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :user_feedback, [:creator_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :user_upgrades, [:purchaser_id, :created_at], algorithm: :concurrently, where: "status IN (20, 30)", name: "index_completed_user_upgrades_on_updater_id_and_created_at", if_not_exists: true
    add_index :user_name_change_requests, [:user_id, :created_at], algorithm: :concurrently, if_not_exists: true
    add_index :wiki_page_versions, [:updater_id, :created_at], algorithm: :concurrently, if_not_exists: true

    add_index :forum_posts, [:topic_id, :id], algorithm: :concurrently, if_not_exists: true
    add_index :users, :bit_prefs, where: "get_bit(bit_prefs::bit(31), 24) = 1", algorithm: :concurrently, name: "index_users_on_enable_private_favorites", if_not_exists: true # users.enable_private_favorites = true
  end
end
