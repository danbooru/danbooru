class AddTagRelationshipForumPostIndices < ActiveRecord::Migration[5.2]
  def change
    execute "set statement_timeout = 0"
    add_index :tag_aliases, :forum_post_id
    add_index :tag_implications, :forum_post_id
    add_index :bulk_update_requests, :forum_post_id
  end
end
