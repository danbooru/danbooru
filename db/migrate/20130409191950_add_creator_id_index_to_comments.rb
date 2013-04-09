class AddCreatorIdIndexToComments < ActiveRecord::Migration
  def change
    execute "set statement_timeout = 0"
    add_index :comments, :creator_id
  end
end
