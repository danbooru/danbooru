class AddIndexesOnComments < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :comments, :score, if_not_exists: true, algorithm: :concurrently
    add_index :comments, :is_deleted, where: "is_deleted = true", if_not_exists: true, algorithm: :concurrently
    add_index :comments, :is_sticky, where: "is_sticky = true", if_not_exists: true, algorithm: :concurrently
    add_index :comments, :do_not_bump_post, where: "do_not_bump_post = true", if_not_exists: true, algorithm: :concurrently
    add_index :comments, :updater_id, where: "updater_id IS NOT NULL", if_not_exists: true, algorithm: :concurrently
  end
end
