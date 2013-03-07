class AddSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :enable_post_navigation, :boolean, :null => false, :default => true
    add_column :users, :new_post_navigation_layout, :boolean, :null => false, :default => true
    add_column :users, :enable_privacy_mode, :boolean, :null => false, :default => false
  end
end
