class UpdatePostEventsToVersion2 < ActiveRecord::Migration[7.0]
  def change
    replace_view :post_events, version: 2, revert_to_version: 1
  end
end
