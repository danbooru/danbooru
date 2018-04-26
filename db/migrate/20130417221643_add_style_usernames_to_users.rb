class AddStyleUsernamesToUsers < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :users, :style_usernames, :boolean, :null => false, :default => false
  end
end
