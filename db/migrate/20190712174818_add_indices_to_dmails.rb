class AddIndicesToDmails < ActiveRecord::Migration[5.2]
  def change
    add_index :dmails, :from_id
    add_index :dmails, :created_at
  end
end
