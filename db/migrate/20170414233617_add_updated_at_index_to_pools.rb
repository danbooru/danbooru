class AddUpdatedAtIndexToPools < ActiveRecord::Migration[4.2]
  def change
    add_index :pools, :updated_at
  end
end
