class AddForumPostIdToTagRequests < ActiveRecord::Migration[4.2]
  def change
    ApplicationRecord.without_timeout do
      add_column :tag_aliases, :forum_post_id, :integer
      add_column :tag_implications, :forum_post_id, :integer
      add_column :bulk_update_requests, :forum_post_id, :integer
    end
  end
end
