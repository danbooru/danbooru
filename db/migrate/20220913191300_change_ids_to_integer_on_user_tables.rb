class ChangeIdsToIntegerOnUserTables < ActiveRecord::Migration[7.0]
  def up
    change_column :forum_post_votes, :id, :integer
    change_column :moderation_reports, :id, :integer
    change_column :moderation_reports, :model_id, :integer
    change_column :tag_versions, :id, :integer
    change_column :tag_versions, :tag_id, :integer
    change_column :tag_versions, :previous_version_id, :integer
    change_column :tag_versions, :updater_id, :integer
    change_column :user_upgrades, :id, :integer
    change_column :user_upgrades, :recipient_id, :integer
    change_column :user_upgrades, :purchaser_id, :integer
    change_column :user_events, :id, :integer
    change_column :user_events, :user_id, :integer
    change_column :user_events, :user_session_id, :integer
  end

  def down
    change_column :forum_post_votes, :id, :bigint
    change_column :moderation_reports, :id, :bigint
    change_column :moderation_reports, :model_id, :bigint
    change_column :tag_versions, :id, :bigint
    change_column :tag_versions, :tag_id, :bigint
    change_column :tag_versions, :previous_version_id, :bigint
    change_column :tag_versions, :updater_id, :bigint
    change_column :user_upgrades, :id, :bigint
    change_column :user_upgrades, :recipient_id, :bigint
    change_column :user_upgrades, :purchaser_id, :bigint
    change_column :user_events, :id, :bigint
    change_column :user_events, :user_id, :bigint
    change_column :user_events, :user_session_id, :bigint
  end
end
