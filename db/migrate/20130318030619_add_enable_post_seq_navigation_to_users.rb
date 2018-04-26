class AddEnablePostSeqNavigationToUsers < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :users, :enable_sequential_post_navigation, :boolean, :null => false, :default => true
  end
end
