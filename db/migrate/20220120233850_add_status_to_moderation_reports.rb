class AddStatusToModerationReports < ActiveRecord::Migration[7.0]
  def change
    add_column :moderation_reports, :status, :integer, null: false, default: 0
    add_index :moderation_reports, :status
  end
end
