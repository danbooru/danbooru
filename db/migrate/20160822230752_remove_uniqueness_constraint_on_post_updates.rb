class RemoveUniquenessConstraintOnPostUpdates < ActiveRecord::Migration[4.2]
  def up
    execute "alter table post_updates drop constraint unique_post_id"
  end

  def down
  end
end
