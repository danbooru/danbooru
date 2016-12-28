class AddStickyToComments < ActiveRecord::Migration
  def change
    execute "set statement_timeout = 0"
    add_column :comments, :is_sticky, :boolean, null: false, default: false
  end
end
