class RemoveUniquenessConstraintOnPostUpdates < ActiveRecord::Migration
  def up
    execute "alter table post_updates drop constraint unique_post_id"
  end

  def down
  end
end
