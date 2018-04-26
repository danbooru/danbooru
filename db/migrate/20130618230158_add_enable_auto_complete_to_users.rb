class AddEnableAutoCompleteToUsers < ActiveRecord::Migration[4.2]
  def change
    execute("set statement_timeout = 0")
    add_column :users, :enable_auto_complete, :boolean, :null => false, :default => :true
  end
end
