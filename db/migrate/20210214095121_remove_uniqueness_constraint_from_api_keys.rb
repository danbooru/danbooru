class RemoveUniquenessConstraintFromApiKeys < ActiveRecord::Migration[6.1]
  def change
    remove_index :api_keys, :user_id, unique: true
    add_index :api_keys, :user_id, unique: false
  end
end
