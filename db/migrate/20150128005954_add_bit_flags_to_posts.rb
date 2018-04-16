class AddBitFlagsToPosts < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :posts, :bit_flags, "bigint", :null => false, :default => 0
  end
end
