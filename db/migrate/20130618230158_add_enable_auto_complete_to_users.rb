class AddEnableAutoCompleteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :enable_auto_complete, :boolean, :null => false, :default => :true
  end
end
