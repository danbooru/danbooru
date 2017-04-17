class AddUpdatedAtIndexToPools < ActiveRecord::Migration
  def change
  	add_index :pools, :updated_at
  end
end
