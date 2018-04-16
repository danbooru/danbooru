class AddCreatorIdIndexToComments < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_index :comments, :creator_id
  end
end
