class AddIsLockedToTags < ActiveRecord::Migration
  def change
    execute "set statement_timeout = 0"
    add_column :tags, :is_locked, :boolean, :null => false, :default => false
  end
end
