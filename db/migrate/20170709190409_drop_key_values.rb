class DropKeyValues < ActiveRecord::Migration
  def up
    drop_table :key_values
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the lost data"
  end
end
