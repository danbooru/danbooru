class AddBitPrefsToUsers < ActiveRecord::Migration[4.2]
  def up
    execute "set statement_timeout = 0"
    add_column :users, :bit_prefs, "bigint", :null => false, :default => 0
    execute "update users set bit_prefs = bit_prefs | 1 where is_banned = true"
    execute "update users set bit_prefs = bit_prefs | 2 where has_mail = true"
    execute "update users set bit_prefs = bit_prefs | 4 where receive_email_notifications = true"
    execute "update users set bit_prefs = bit_prefs | 8 where always_resize_images = true"
    execute "update users set bit_prefs = bit_prefs | 16 where enable_post_navigation = true"
    execute "update users set bit_prefs = bit_prefs | 32 where new_post_navigation_layout = true"
    execute "update users set bit_prefs = bit_prefs | 64 where enable_privacy_mode = true"
    execute "update users set bit_prefs = bit_prefs | 128 where enable_sequential_post_navigation = true"
    execute "update users set bit_prefs = bit_prefs | 256 where hide_deleted_posts = true"
    execute "update users set bit_prefs = bit_prefs | 512 where style_usernames = true"
    execute "update users set bit_prefs = bit_prefs | 1024 where enable_auto_complete = true"
    execute "update users set bit_prefs = bit_prefs | 2048 where show_deleted_children = true"

    remove_column :users, :is_banned
    remove_column :users, :has_mail
    remove_column :users, :receive_email_notifications
    remove_column :users, :always_resize_images
    remove_column :users, :enable_post_navigation
    remove_column :users, :new_post_navigation_layout
    remove_column :users, :enable_privacy_mode
    remove_column :users, :enable_sequential_post_navigation
    remove_column :users, :hide_deleted_posts
    remove_column :users, :style_usernames
    remove_column :users, :enable_auto_complete
    remove_column :users, :show_deleted_children
  end

  def down
    execute "set statement_timeout = 0"

    add_column :users, :is_banned, :boolean
    add_column :users, :has_mail, :boolean
    add_column :users, :receive_email_notifications, :boolean
    add_column :users, :always_resize_images, :boolean
    add_column :users, :enable_post_navigation, :boolean
    add_column :users, :new_post_navigation_layout, :boolean
    add_column :users, :enable_privacy_mode, :boolean
    add_column :users, :enable_sequential_post_navigation, :boolean
    add_column :users, :hide_deleted_posts, :boolean
    add_column :users, :style_usernames, :boolean
    add_column :users, :enable_auto_complete, :boolean
    add_column :users, :show_deleted_children, :boolean

    execute "update users set is_banned = true where bit_prefs & 1 > 0"
    execute "update users set has_mail = true where bit_prefs & 2 > 0"
    execute "update users set receive_email_notifications = true where bit_prefs & 4 > 0"
    execute "update users set always_resize_images = true where bit_prefs & 8 > 0"
    execute "update users set enable_post_navigation = true where bit_prefs & 16 > 0"
    execute "update users set new_post_navigation_layout = true where bit_prefs & 32 > 0"
    execute "update users set enable_privacy_mode = true where bit_prefs & 64 > 0"
    execute "update users set enable_sequential_post_navigation = true where bit_prefs & 128 > 0"
    execute "update users set hide_deleted_posts = true where bit_prefs & 256 > 0"
    execute "update users set style_usernames = true where bit_prefs & 512 > 0"
    execute "update users set enable_auto_complete = true where bit_prefs & 1024 > 0"
    execute "update users set show_deleted_children = true where bit_prefs & 2048 > 0"

    remove_column :users, :bit_prefs, :integer, :null => false, :default => 0
  end
end
