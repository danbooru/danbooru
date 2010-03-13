class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps
      
      t.column :name, :string, :null => false
      t.column :password_hash, :string, :null => false
      t.column :email, :string
      t.column :email_verification_key, :string
      t.column :inviter_id, :integer
      t.column :is_banned, :boolean, :null => false, :default => false
      t.column :is_privileged, :boolean, :null => false, :default => false
      t.column :is_contributor, :boolean, :null => false, :default => false
      t.column :is_janitor, :boolean, :null => false, :default => false
      t.column :is_moderator, :boolean, :null => false, :default => false
      t.column :is_admin, :boolean, :null => false, :default => false
      t.column :base_upload_limit, :integer, :null => false, :default => 10
      
      # Cached data
      t.column :last_logged_in_at, :datetime
      t.column :last_forum_read_at, :datetime
      t.column :has_mail, :boolean, :null => false, :default => false
      
      # Profile settings
      t.column :receive_email_notifications, :boolean, :null => false, :default => false
      t.column :comment_threshold, :integer, :null => false, :default => -1
      t.column :always_resize_images, :boolean, :null => false, :default => false
      t.column :default_image_size, :string, :null => false, :default => "medium"
      t.column :favorite_tags, :text
      t.column :blacklisted_tags, :text
      t.column :time_zone, :string, :null => false, :default => "Eastern Time (US & Canada)"
    end
    
    execute "CREATE UNIQUE INDEX index_users_on_name ON users ((lower(name)))"
    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table :users
  end
end
