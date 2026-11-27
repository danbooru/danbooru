# frozen_string_literal: true

class DisableFastupdateOnFavoriteGroupsPostIdsIndex < ActiveRecord::Migration[8.1]
  def up
    execute "ALTER INDEX index_favorite_groups_on_post_ids SET (fastupdate = off)"

    # Turning off fastupdate doesn't flush entries already in the pending list.
    execute "SELECT gin_clean_pending_list('index_favorite_groups_on_post_ids'::regclass)"
  end

  def down
    execute "ALTER INDEX index_favorite_groups_on_post_ids RESET (fastupdate)"
  end
end
